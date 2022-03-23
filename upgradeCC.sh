#!/usr/bin/env bash

if [ $# -ne 1 ] ; then
    printf 'Usage: ./upgradeCC.sh <version>\n'
    exit
fi

cd ./chaincode; go fmt ./...; cd ..

version=$1

curl -sS -k -X POST \
    'https://localhost:3000/api/v1/network/channel/chaincode/install' \
    -H 'Content-Type: application/json' \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    -d "{
            \"channelName\": \"mainchannel\",
            \"chaincode\": \"gofabcar-cc\",
            \"chaincodeVersion\": \"${version}\"
        }" > /dev/null

printf "\nUpgrade chaincode to version $1\n"
curl -k -X POST \
    'https://localhost:3000/api/v1/network/channel/chaincode/upgrade' \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    -H 'Content-Type: application/json' \
    -d "{
            \"channelName\": \"mainchannel\",
            \"chaincode\": \"gofabcar-cc\",
            \"chaincodeVersion\": \"${version}\",
            \"chaincodeType\": \"golang\"
        }"

printf '\n'
