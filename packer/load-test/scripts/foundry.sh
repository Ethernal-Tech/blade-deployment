#!/bin/bash -e
echo "Installing foundry"
curl -L https://foundry.paradigm.xyz | bash
/root/.foundry/bin/foundryup
sudo cp /root/.foundry/bin/* /usr/local/bin
