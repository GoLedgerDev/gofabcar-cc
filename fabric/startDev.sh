#!/usr/bin/env bash

# set -x

generate() {
  sudo rm -rf crypto-config
  mkdir -p crypto-config
  sudo rm -rf ca/org1/fabric-ca-server.db
  mkdir -p ca/org1
  source scripts/generateCerts.sh
  generateCerts
  if [[ $? -ne 0 ]]; then
    echo "Error at cert generation"
    exit 1
  fi

  # Create rest-certs folder
  REST_CERTS_FOLDER=./crypto-config/rest-certs

  # Copy org1 rest-certs
  ORGNAME=org1.example.com
  PRIVATE_KEY_PATH=$(ls $PWD/crypto-config/peerOrganizations/${ORGNAME}/users/Admin.${ORGNAME}/msp/keystore/*_sk)
  PRIVATE_KEY=$(basename $PRIVATE_KEY_PATH)
  echo $PRIVATEKEY
  mkdir -p $REST_CERTS_FOLDER/${ORGNAME}
  # Copy admin privkey to rest-certs
  cp $PRIVATE_KEY_PATH $REST_CERTS_FOLDER/${ORGNAME}/admin.key
  # Copy admin cert to rest-certs
  ADMINCERT_PATH=$PWD/crypto-config/peerOrganizations/${ORGNAME}/users/Admin.${ORGNAME}/msp/signcerts/Admin.${ORGNAME}-cert.pem
  cp $ADMINCERT_PATH $REST_CERTS_FOLDER/${ORGNAME}/admin.cert
  # Copy cacert to rest-certs
  CACERT_PATH=$PWD/crypto-config/peerOrganizations/${ORGNAME}/peers/peer0.${ORGNAME}/tls/ca.crt
  cp $CACERT_PATH $REST_CERTS_FOLDER/${ORGNAME}/ca.crt
}

start_network() {
  CHAINCODE_NAME=gofabcar-cc
  ./clearDev.sh
  docker network create ${CHAINCODE_NAME}-net
  # docker-compose -f docker-compose-ca.yaml up -d
  docker-compose pull
  docker-compose up -d
  sleep 30

  printf '\n\nCreate channel - mainchannel\n'
  curl -k --request POST \
  --url 'https://localhost:3000/api/v1/network/channel/create?channelName=mainchannel' \
  --header 'gofabricversion: 0.9.0' \
  -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
  --form channeltx=@./channel-artifacts/channel.tx

  sleep 10 # wait for channel RAFT to be available

  printf '\n\nJoin org1 to channel\n'
  curl -k -X POST \
    https://localhost:3000/api/v1/network/channel/join \
    -H 'Content-Type: application/json' \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    -d '{
  "channelName": "mainchannel"
  }	'

  printf '\n\nUpdate anchor peers on org1\n'
  curl -k -X POST \
    https://localhost:3000/api/v1/network/channel/anchorPeers?channelName=mainchannel \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    --form anchorstx=@./channel-artifacts/org1MSPanchors.tx

  printf '\n\nInstall chaincode on org1\n'
  curl -sS -k -X POST \
    https://localhost:3000/api/v1/network/channel/chaincode/install \
    -H 'Content-Type: application/json' \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    -d '{
          "chaincode":        "gofabcar-cc",
          "channelName":      "mainchannel",
          "chaincodeVersion": "0.1"
        }'

  printf '\n\nInstantiate chaincode\n'
  curl -k -X POST \
    https://localhost:3000/api/v1/network/channel/chaincode/instantiate \
    -H 'Content-Type: application/json' \
    --header 'gofabricversion: 0.9.0' \
    -H 'magicnumber: dfff482c-1df5-42ad-95d4-d8d72b2398be' \
    -d "{
          \"channelName\": \"mainchannel\",
          \"chaincode\": \"gofabcar-cc\",
          \"chaincodeVersion\": \"0.1\"
      }"

  printf '\n\n'
}

create_artifacts() {
  rm -rf channel-artifacts
  mkdir channel-artifacts
  export FABRIC_CFG_PATH=$PWD
  configtxgen -profile SingleNodeEtcdRaft -channelID sys-channel -outputBlock ./channel-artifacts/genesis.block
  export CHANNEL_NAME=mainchannel && configtxgen -profile OrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
  configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg org1MSP
}

export IMAGE_TAG=1.4
export COMPOSE_PROJECT_NAME=fabric
if [ "$OSTYPE" == "linux-gnu" ] ; then 
  export PATH=$PWD/bin:$PATH
fi

###############################################
######### Script starts here ##################
###############################################
case "$1" in
  generate)
    generate
    create_artifacts
    exit 1
    ;;
  up)
    start_network
    exit 1
    ;;
  *)
    if [ ! -f "channel-artifacts/channel.tx" ]; then
      echo "Certs not found. Generating certs."
      generate
      create_artifacts
    fi
    start_network
    ;;
esac
