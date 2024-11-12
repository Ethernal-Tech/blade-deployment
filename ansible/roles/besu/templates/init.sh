#!/bin/bash

docker run -v $PWD:/app -w /app hyperledger/besu:latest operator generate-blockchain-config --c
onfig-file=/var/lib/besu/initConfig.json --to=networkFiles --private-key-file-name=key

tar czf besu.tar.gz /var/lib/besu/networkFiles/
aws s3 cp besu.tar.gz s3://besu-state-bucket/besu.tar.gz