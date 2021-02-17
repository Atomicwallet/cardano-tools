#!/bin/bash
set -e

export TMP_CARDANO_PATH=$(mktemp -d)
trap 'rm -rf -- "$TMP_CARDANO_PATH"' EXIT

echo $TMP_CARDANO_PATH
curl -s https://hydra.iohk.io/build/5577872/download/1/cardano-node-1.25.0-macos.tar.gz | \
    tar -v -C ${TMP_CARDANO_PATH} -xzf - \
    cardano-cli \
    libcharset.1.dylib \
    libffi.7.dylib \
    libgmp.10.dylib \
    libiconv-nocharset.dylib \
    libiconv.dylib \
    libsodium.23.dylib \
    libz.dylib

cd ${TMP_CARDANO_PATH}

# Install cardano-cli
cp ./cardano-cli /usr/local/bin/
chmod +x /usr/local/bin/cardano-cli

# Install libs
mkdir -p /usr/local/lib/cardano
cp *.dylib  /usr/local/lib/cardano/
for lib in `ls *.dylib`; do ln -sf /usr/local/lib/cardano/$lib /usr/local/lib/; done


