#!/bin/bash

set -e

docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file node.skey \
--signing-key-file stake.skey \
--mainnet \
--out-file tx.signed
