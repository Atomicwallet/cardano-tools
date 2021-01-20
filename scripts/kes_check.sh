#!/bin/bash
## Script is taken from Cardano Russian community Telegram channel. 

wget 
genesisfile="${genesisfile:/tmp/mainnet-shelley-genesis.json}"

if [ ! -f $genesisfile ]; then
    echo "File does not exists: $genesisfile"
    exit 1
fi

#Calculating current KES-Period
startTimeGenesis=$(cat ${genesisfile} | jq -r .systemStart)
startTimeSec=$(date --date=${startTimeGenesis} +%s)     

MAINNET_NETWORK_MAGIG='764824073'
MAINNET_SHELLEY_START='2020-07-29T21:46:31Z'
networkMagic=$(cat ${genesisfile} | jq -r .networkMagic)

if [ "$networkMagic" == "$MAINNET_NETWORK_MAGIG" ]
then
    startTimeShelleyInMainnetSec=$(date --date="$MAINNET_SHELLEY_START" +%s)
else
    startTimeShelleyInMainnetSec=$startTimeSec
fi

slotsCountInByronEra=$(( ( startTimeShelleyInMainnetSec - startTimeSec ) / 20 ))

currentTimeSec=$(date -u +%s)                          
slotsPerKESPeriod=$(cat ${genesisfile} | jq -r .slotsPerKESPeriod)
slotLength=$(cat ${genesisfile} | jq -r .slotLength)
currentKESperiod=$(( (${currentTimeSec}-${startTimeSec}) / (${slotsPerKESPeriod}*${slotLength}) ))


shelleyStartFromKESPeriod=$(( (slotsCountInByronEra ) / slotsPerKESPeriod +1 ))

slotsCountAfterByronEra=$(( ( currentTimeSec - startTimeShelleyInMainnetSec ) / slotLength ))
currentKESperiod=$(( (slotsCountInByronEra + slotsCountAfterByronEra ) / slotsPerKESPeriod ))


#Calculating Expire KES Period and Date/Time
maxKESEvolutions=$(cat ${genesisfile} | jq -r .maxKESEvolutions)
expiresKESperiod=$(( ${currentKESperiod} + ${maxKESEvolutions} ))
expireTimeSec=$(( ${startTimeSec} + (${slotLength}*${expiresKESperiod}*${slotsPerKESPeriod}) ))
expireDate=$(date --date=@${expireTimeSec} +%Y-%m-%dT%H-%M-%S)

echo -e "Current KES Period: ${currentKESperiod}"
echo -e "KES Keys expire after Period: ${expiresKESperiod} (${expireDate})"
echo -e "Shelley started at ${MAINNET_SHELLEY_START} with ${shelleyStartFromKESPeriod} KES period"