#!/bin/bash

docker run -v $PWD:/app -w /app hyperledger/besu:latest operator generate-blockchain-config --c
onfig-file=./modules/ec2/scripts/genesis.json --to=networkFiles --private-key-file-name=key

docker run --name besu -d --net host -v $PWD:/app -w /app hyperledger/besu:latest --data-path=data --genesis-file=./networkFiles/genesis.json --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --p2p-port=10001 --rpc-http-port=10002 --rpc-http-host=0.0.0.0

enode://f162e336c37272c4fbed6b45a6c92e18836f0bf57533c1782badcc4c2f098ea84fb895d70b4a15cedbdf2bdb83d6ddb2a3949e575b6d8f06e262b327165121c0@127.0.0.1:10001



aws s3 cp s3://besu-state-bucket/besu.tar.gz besu.tar.gz
tar -xf besu.tar.gz
mkdir data
cp ./networkFiles

docker run --name besu -d --net host -v $PWD:/app -w /app hyperledger/besu:latest --data-path=data --genesis-file=./networkFiles/genesis.json --bootnodes=enode://f162e336c37272c4fbed6b45a6c92e18836f0bf57533c1782badcc4c2f098ea84fb895d70b4a15cedbdf2bdb83d6ddb2a3949e575b6d8f06e262b327165121c0@10.10.65.143:10001 --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --p2p-port=10001 --rpc-http-port=10002 --rpc-http-host=0.0.0.0


cd /var/lib/besu
docker stop besu
docker container rm besu
rm -rf data
mkdir data
myarray=($(find ./networkFiles/keys -maxdepth 1 -mindepth 1 -type d -printf '%f '))
cp ./networkFiles/keys/${myarray[1]}/* ./data