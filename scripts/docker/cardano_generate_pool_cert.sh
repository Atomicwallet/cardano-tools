#!/bin/bash
set -e

# Export env variables
# export CARDANO_PLEDGE_POOL=100000
# export CARDANO_COST=345000000
# export CARDANO_PLEDGE_POOL=1000000000
# export CARDANO_MARGIN=0.03
# export CARDANO_RALAY_HOST=cardano-relay.domain.com
# export CARDANO_META_URL=https://domain.com
# export CARDANO_META_HASH=e4a0039299693d0a952bedf578033ee6d76bafdd21a731e475923d40ac91d761

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
--metadata-url ${CARDANO_META_URL} \
--metadata-hash ${CARDANO_META_HASH} \
--out-file pool.cert