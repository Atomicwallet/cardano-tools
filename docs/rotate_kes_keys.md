# Rotate pool's KES keys

1. Go to cold keys directory
```
cd keys
```

2. Git clone 
```
git clone https://github.com/Atomicwallet/cardano-tools
```

or update if repo exists

```
cd cardano-tools
git pull
cd ..
```

3. Run script

```
./cardano-tools/scripts/docker/rotate_kes_keys.sh
```

4. Copy `kes.vkey` to your cold environment.

5. Copy `kes.skey` and `node.cert` to server and restart validator node with new keys.