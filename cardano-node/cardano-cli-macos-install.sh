#!/bin/bash
set -e

export TMP_CARDANO_PATH=$(mktemp -d)

export AS_USER=$SUDO_USER
if [[ -z $SUDO_USER ]]; then
    export AS_USER=$USER
fi

trap 'rm -rf -- "$TMP_CARDANO_PATH"' EXIT

curl -s https://update-cardano-mainnet.iohk.io/cardano-node-releases/cardano-node-1.35.4-macos.tar.gz | \
    tar -v -C ${TMP_CARDANO_PATH} -xzf - \
    cardano-cli \
    cardano-node \
    libcharset.1.dylib \
    libffi.8.dylib \
    libgmp.10.dylib \
    libiconv-nocharset.dylib \
    libiconv.dylib \
    libsodium.23.dylib \
    libz.dylib \
    libssl.3.dylib \
    libcrypto.3.dylib \
    libsecp256k1.0.dylib

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

wget -q https://book.world.dev.cardano.org/environments/mainnet/config.json -O ~/cardano-node/configuration/cardano/mainnet-config.json
wget -q https://book.world.dev.cardano.org/environments/mainnet/byron-genesis.json -O ~/cardano-node/configuration/cardano/byron-genesis.json
wget -q https://book.world.dev.cardano.org/environments/mainnet/shelley-genesis.json -O ~/cardano-node/configuration/cardano/shelley-genesis.json
wget -q https://book.world.dev.cardano.org/environments/mainnet/topology.json -O ~/cardano-node/configuration/cardano/mainnet-topology.json
wget -q https://book.world.dev.cardano.org/environments/mainnet/alonzo-genesis.json -O ~/cardano-node/configuration/cardano/alonzo-genesis.json
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/system/cardano-node.mac.plist -O ${TMP_CARDANO_PATH}/cardano-node.mac.plist
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano-sync-status -O /usr/local/bin/cardano-sync-status
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano_generate_keys -O /usr/local/bin/cardano_generate_keys
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano-stop -O /usr/local/bin/cardano-stop
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano-start -O /usr/local/bin/cardano-start
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano_calm_rewards -O /usr/local/bin/cardano_calm_rewards
wget -q https://raw.githubusercontent.com/Atomicwallet/cardano-tools/main/cardano-node/bin/cardano_send_amount -O /usr/local/bin/cardano_send_amount

chown -R ${AS_USER} ~/cardano-node/

chmod +x /usr/local/bin/cardano-sync-status
chmod +x /usr/local/bin/cardano_generate_keys
chmod +x /usr/local/bin/cardano_calm_rewards
chmod +x /usr/local/bin/cardano_send_amount
chmod +x /usr/local/bin/cardano-stop
chmod +x /usr/local/bin/cardano-start

envsubst < ${TMP_CARDANO_PATH}/cardano-node.mac.plist > ~/Library/LaunchAgents/cardano-node.plist
