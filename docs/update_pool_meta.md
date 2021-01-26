# Update pool 

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

Sent `pool.cert` to validator server

## Make raw tw (Producer side)

Make `tx.raw`
```
/opt/cardano/scripts/reg_stake_pool_update.sh
```

Sent `tx.raw` to client

## Sign tx (Client side)

Put `tx.raw` to ./keys folder and sign one

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