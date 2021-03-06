#!/bin/bash
set -e

export TMP_CARDANO_PATH=$(mktemp -d)
trap 'rm -rf -- "$TMP_CARDANO_PATH"' EXIT

curl -s https://hydra.iohk.io/build/5577872/download/1/cardano-node-1.25.0-macos.tar.gz | \
    tar -v -C ${TMP_CARDANO_PATH} -xzf - \
    cardano-cli \
    cardano-node \
    libcharset.1.dylib \
    libffi.7.dylib \
    libgmp.10.dylib \
    libiconv-nocharset.dylib \
    libiconv.dylib \
    libsodium.23.dylib \
    libz.dylib

# Install cardano-cli
cp ${TMP_CARDANO_PATH}/cardano-cli /usr/local/bin/
cp ${TMP_CARDANO_PATH}/cardano-node /usr/local/bin/
chmod +x /usr/local/bin/cardano-cli
chmod +x /usr/local/bin/cardano-node

# Install libs
mkdir -p /usr/local/lib/cardano
cp ${TMP_CARDANO_PATH}/*.dylib  /usr/local/lib/cardano/
for lib in `ls ${TMP_CARDANO_PATH}/*.dylib| xargs -n 1 basename`; do ln -sf /usr/local/lib/cardano/$lib /usr/local/lib/; done

# Init config

mkdir -p ~/cardano-node/configuration/cardano/
mkdir -p ~/cardano-node/data

wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json -O ~/cardano-node/configuration/cardano/mainnet-config.json
wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json -O ~/cardano-node/configuration/cardano/mainnet-byron-genesis.json
wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json -O ~/cardano-node/configuration/cardano/mainnet-shelley-genesis.json
wget -q https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json -O ~/cardano-node/configuration/cardano/mainnet-topology.json
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/system/cardano-node.mac.plist -O ${TMP_CARDANO_PATH}/cardano-node.mac.plist
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano-sync-status -O /usr/local/bin/cardano-sync-status

chmod +x /usr/local/bin/cardano-sync-status

export USER=$(whoami)
envsubst < ${TMP_CARDANO_PATH}/cardano-node.mac.plist > ~/Library/LaunchAgents/cardano-node.plist
launchctl unload  ~/Library/LaunchAgents/cardano-node.plist 2>/dev/null
launchctl load  ~/Library/LaunchAgents/cardano-node.plist 2>/dev/null

