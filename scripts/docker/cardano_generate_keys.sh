#!/bin/bash

set -e

if [[ ! -f kes.vkey && ! -f kes.skey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley node key-gen-KES \
  --verification-key-file kes.vkey \
  --signing-key-file kes.skey
else
  echo "KES keys exists"
fi

if [[ ! -f node.vkey && ! -f node.skey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley node key-gen \
  --cold-verification-key-file node.vkey \
  --cold-signing-key-file node.skey \
  --operational-certificate-issue-counter node.counter
else
  echo "NODE keys exists"
fi

slotNo=$(curl -s https://cardano-atomic-01.atomicwallet.io/lastblock| jq .slot_no)
slotsPerKESPeriod=129600
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}

if [[ ! -f node.cert ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley node issue-op-cert \
  --kes-verification-key-file kes.vkey \
  --cold-signing-key-file node.skey \
  --operational-certificate-issue-counter node.counter \
  --kes-period ${startKesPeriod} \
  --out-file node.cert
else
  echo "node.cert keys exists"
fi

if [[ ! -f vrf.vkey  && ! -f vrf.skey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley node key-gen-VRF \
  --verification-key-file vrf.vkey \
  --signing-key-file vrf.skey
else
  echo "VRF keys exists"
fi

if [[ ! -f payment.vkey  && ! -f payment.skey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley address key-gen \
  --verification-key-file payment.vkey \
  --signing-key-file payment.skey
else
  echo "Payment keys exists"
fi

if [[ ! -f stake.vkey  && ! -f stake.skey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley stake-address key-gen \
  --verification-key-file stake.vkey \
  --signing-key-file stake.skey
else
  echo "Stake keys exists"
fi

if [[ -f stake.vkey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley stake-address build \
  --stake-verification-key-file stake.vkey \
  --out-file stake.addr \
  --mainnet
else
  echo "Can't generate stake address. Stake key doesn't exists"
fi

if [[ -f stake.vkey && -f payment.vkey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley address build \
  --payment-verification-key-file payment.vkey \
  --stake-verification-key-file stake.vkey \
  --out-file payment.addr \
  --mainnet
else
  echo "Can't generate payment address. Stake and Payment keys don't exists"
fi

if [[ -f stake.vkey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0  \
  cardano-cli shelley stake-address registration-certificate \
  --stake-verification-key-file stake.vkey \
  --out-file stake.cert
else
  echo "Can't generate stake cert. Stake key doesn't exists"
fi

if [[ -f stake.vkey  && -f node.vkey ]]; then
  docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
  cardano-cli shelley stake-address delegation-certificate \
  --stake-verification-key-file stake.vkey \
  --cold-verification-key-file node.vkey \
  --out-file deleg.cert
else
  echo "Can't generate stake cert. Stake or Node keys don't exists"
fi
