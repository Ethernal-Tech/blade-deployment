#!/bin/bash
echo Installing foundry
curl -L https://foundry.paradigm.xyz | bash
sleep 10
$HOME/.foundry/bin/foundryup
sudo cp $HOME/.foundry/bin/* /usr/local/bin