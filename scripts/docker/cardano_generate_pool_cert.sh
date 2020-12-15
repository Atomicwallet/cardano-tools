#!/bin/bash
set -e

# Export env variables
# export CARDANO_PLEDGE_POOL=1000000000
# export CARDANO_COST=345000000
# export CARDANO_MARGIN=0.05
# export CARDANO_RALAY_HOST=cardano-relay.domain.com
# export CARDANO_METADATA_URL=https://domain.com/poolMetadata.json

#!/bin/bash
set -ex

curl -o poolMetadata.json -fSL ${CARDANO_METADATA_URL}
CARDANO_METADATA_HASH=$(docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.21.1 cardano-cli shelley stake-pool metadata-hash --pool-metadata-file poolMetaData.json)

docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
cardano-cli shelley stake-pool registration-certificate \
--cold-verification-key-file node.vkey \
--vrf-verification-key-file vrf.vkey \
--pool-pledge ${CARDANO_PLEDGE_POOL} \
--pool-cost ${CARDANO_COST} \
--pool-margin ${CARDANO_MARGIN} \
--pool-reward-account-verification-key-file stake.vkey \
--pool-owner-stake-verification-key-file stake.vkey \
--mainnet \
--single-host-pool-relay ${CARDANO_RALAY_HOST} \
--pool-relay-port 6001 \
--metadata-url ${CARDANO_METADATA_URL} \
--metadata-hash ${CARDANO_METADATA_HASH} \
--out-file pool.cert
