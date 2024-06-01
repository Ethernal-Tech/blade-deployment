#!/bin/bash -e
echo "Installing polycli"
sudo wget https://github.com/maticnetwork/polygon-cli/releases/download/v${POLYCLI_TAG}/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz -O /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo chmod 0600 /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo tar -C /opt/ -xzf /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo ln -s /opt/polycli_${POLYCLI_TAG}_linux_amd64/polycli /usr/local/bin/polycli
sudo rm -rf /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
