#!/bin/bash
set -e

keys_path=${CARDANO_KEYS_PATH:./keys}
# Get balance of the rewards address

REWARD_BALANCE=$(docker exec cardano-node sh -c 'cardano-cli query stake-address-info --mainnet --mary-era --address $(cat /keys/stake.addr)'| jq .[0].rewardAccountBalance)
echo "REWARD_BALANCE: $REWARD_BALANCE"

# Get payment address balance

docker exec cardano-node sh -c 'cardano-cli query utxo --mainnet --mary-era --address $(cat /keys/payment.addr) --out-file /txs/balance.json'
PAYMENT_TX_HASH=$(cat ${keys_path}/balance.json | jq 'keys'[0])
PAYMENT_BALANCE=$(cat ${keys_path}balance.json |  jq 'first(.[] | .amount[0])')
echo "PAYMENT_TX_HASH: $PAYMENT_TX_HASH"
echo "PAYMENT_BALANCE: $PAYMENT_BALANCE"

# Draft the withdraw transaction to transfer the rewards to a payment.addr

docker exec -it cardano-node sh -c "cardano-cli transaction build-raw --tx-in $PAYMENT_TX_HASH \
--tx-out $(cat payment.addr)+0 \
--withdrawal $(cat stake.addr)+$REWARD_BALANCE \
--invalid-hereafter 0 \
--fee 0 \
--out-file /config/withdraw_rewards.raw"

# Calculate transaction fees

FEE_RAW=$(docker exec -it cardano-node sh -c "cardano-cli transaction calculate-min-fee \
--mainnet \
--tx-body-file /config/withdraw_rewards.raw  \
--tx-in-count 1 \
--tx-out-count 1 \
--witness-count 1 \
--byron-witness-count 0 \
--protocol-params-file /config/params.json")
FEE=$(echo $FEE_RAW | awk '{print $1}')
echo "FEE: $FEE"

# Determine the TTL (time to Live) for the transaction

TX_TTL_LIMIT_SLOTS=86400
SLOT_NO=$(docker exec cardano-node cardano-cli query tip --mainnet| jq .slotNo)
TX_TTL=$(expr $SLOT_NO + $TX_TTL_LIMIT_SLOTS)
echo "SLOT_NO: $SLOT_NO"
echo "TX_TTL: $TX_TTL"

# Calculate the change to send back to payment.addr

echo "expr $PAYMENT_BALANCE - $FEE + $REWARD_BALANCE"
PAYMENT_CHANGE_BACK=$(expr $PAYMENT_BALANCE - $FEE + $REWARD_BALANCE)
echo "PAYMENT_CHANGE_BACK: $PAYMENT_CHANGE_BACK"

# Build the raw transaction
docker exec cardano-node sh -c "cardano-cli transaction build-raw --tx-in $PAYMENT_TX_HASH \
--tx-out $(cat payment.addr)+${PAYMENT_CHANGE_BACK} \
--withdrawal $(cat stake.addr)+${REWARD_BALANCE} \
--invalid-hereafter $TX_TTL \
--fee $FEE \
--out-file withdraw_rewards.raw"