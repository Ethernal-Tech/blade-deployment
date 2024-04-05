#!/bin/bash
echo Installing polycli
sudo wget https://github.com/maticnetwork/polygon-cli/releases/download/v$POLYCLI_TAG/polycli_"$POLYCLI_TAG"_linux_amd64.tar.gz -O /opt/polycli_"$POLYCLI_TAG"_linux_amd64.tar.gz
sudo tar -C /usr/local/ -xzf /opt/polycli_"$POLYCLI_TAG"_linux_amd64.tar.gz
sudo ln -s /usr/local/polycli_"$POLYCLI_TAG"_linux_amd64/polycli /usr/local/bin/polycli 
