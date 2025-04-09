#! /bin/bash

git clone https://github.com/chainflag/eth-faucet.git
pushd eth-faucet
go generate
go build -o eth-faucet
sudo cp eth-faucet /usr/local/bin
which eth-faucet
