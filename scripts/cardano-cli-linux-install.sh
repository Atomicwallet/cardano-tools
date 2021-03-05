#!/bin/bash
set -e

curl -s wget https://hydra.iohk.io/build/5721733/download/1/cardano-node-1.25.0-linux.tar.gz | \
    tar -v -C /usr/local/bin -xzf - cardano-cli cardano-node 

chmod +x /usr/local/bin/cardano-cli
chmod +x /usr/local/bin/cardano-node



