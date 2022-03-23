#!/usr/bin/env bash

# Stop and remove containers
docker-compose rm -f
docker images -a | grep "dev-peer" | awk '{print $1}' | xargs docker rmi -f
docker-compose down --volumes
docker network create gofabcar-cc-net
docker volume rm $(docker volume ls -q)

yes | docker volume prune

docker container rm -f ccapi.org1.example.com
