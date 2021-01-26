# Update pool 

## Generate keys

```
mkdir ./keys
cd ./keys
git clone https://github.com/Atomicwallet/cardano-tools
./cardano-tools/scripts/docker/cardano_generate_keys.sh
```

## Generate pool cert (Client side)
Set env variables
```
export CARDANO_PLEDGE_POOL=1000000000
export CARDANO_COST=345000000
export CARDANO_MARGIN=0.05
export CARDANO_RALAY_HOST=cardano-relay.domain.com
export CARDANO_METADATA_URL=https://domain.com/poolMetadata.json
```
Run script
```
cd ./keys
scripts/docker/cardano_generate_pool_cert.sh
```

Sent to validator server:
- pool.cert
- kes.skey
- vrf.skey
- node.cert
- deleg.cert
- stake.cert 
- payment.addr
- stake.addr

## Run validator node (Producer side)

```
cardano-node run \
  --config /config/mainnet-config.json \
  --database-path /data/db \
  --topology /config/mainnet-topology.json \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --socket-path /ipc/node.socket \
  --shelley-kes-key /keys/kes.skey \
  --shelley-vrf-key /keys/vrf.skey \
  --shelley-operational-certificate /keys/node.cert
```

## Make raw tw (Producer side)

Make `tx.raw`
```
/opt/cardano/scripts/reg_stake_pool.sh
```

Sent `tx.raw` to client

## Sign tx (Client side)

Put `tx.raw` into `./keys` folder and sign one

```
cd ./keys
/opt/cardano/scripts/cardano_sign_tx.sh
```

Sent `tx.signed` to producer

## Submit tx (Producer side)

```
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```