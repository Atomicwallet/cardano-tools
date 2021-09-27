#!/bin/bash

slotNo=$(curl -s https://cardano-atomic-01.atomicwallet.io/lastblock| jq .slot_no)
slotsPerKESPeriod=129600
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}

docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
    cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey

docker run -it --rm -v ${PWD}:/keys --workdir /keys --entrypoint "" inputoutput/cardano-node:1.23.0 \
    cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter \
    --kes-period ${startKesPeriod} \
    --out-file node.cert
