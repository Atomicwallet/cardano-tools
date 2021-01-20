# Get slotNo

## With cardano-cli
``` 
# cardano-cli  query tip --mainnet | jq .slotNo
19594414
```


## With cardano explorer api 
[cardano explorer api docs](https://input-output-hk.github.io/cardano-rest/explorer-api/)   
```
# cbeEpoch=$(curl -s http://127.0.0.1:8100/api/blocks/pages| jq .'Right[1][0].cbeEpoch')
# cbeSlot=$(curl -s http://127.0.0.1:8100/api/blocks/pages| jq .'Right[1][0].cbeSlot')
# slotNo=$(expr 4492800 + $(expr $cbeEpoch - 208) * 432000 + $cbeSlot)
# echo $slotNo
19594414
```

## With prometheus metrics
```
# curl -s  http://localhost:12799/metrics | grep cardano_node_ChainDB_metrics_slotNum_int
cardano_node_ChainDB_metrics_slotNum_int 19594671
```