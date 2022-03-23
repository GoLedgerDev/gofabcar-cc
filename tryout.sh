#!/usr/bin/env bash

if [ $# -lt 1 ] ; then
  HOST="localhost"
else
  HOST=$1
fi

printf "Sending requests to ${HOST}"

printf '\n\nGet Header\n';
curl -k \
  "http://${HOST}:80/api/query/getHeader" \
  -H 'cache-control: no-cache'


printf '\n\nGet Transactions\n';
curl -k \
  "http://${HOST}:80/api/query/getTx" \
  -H 'cache-control: no-cache'

printf '\n\nGet CreateAsset definition\n';
curl -k -X POST \
  "http://${HOST}:80/api/query/getTx" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
        "txName": "createAsset"
      }'


printf '\n\nGet Asset Types\n';
curl -k \
  "http://${HOST}:80/api/query/getSchema/" \
  -H 'cache-control: no-cache'

print '\n'