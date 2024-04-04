#!/bin/bash -e

#######################
### COMMON PACKAGES ###
#######################
echo "Installing common packages"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install make jq

###############
### FOUNDRY ###
###############
echo "Installing foundry"
curl -L https://foundry.paradigm.xyz | bash
/root/.foundry/bin/foundryup
sudo cp /root/.foundry/bin/* /usr/local/bin

##############
### GOLANG ###
##############
echo "Installing golang"
rm -rf /usr/local/go
sudo wget https://go.dev/dl/go${GO_TAG}.tar.gz /opt/go${GO_TAG}.tar.gz
sudo chmod 0755 /opt/go${GO_TAG}.tar.gz
sudo tar -C /usr/local/ -xzf /opt/go${GO_TAG}.tar.gz
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
rm -rf /opt/go${GO_TAG}.tar.gz

###############
### POLYCLI ###
###############
echo "Installing polycli"
sudo wget https://github.com/maticnetwork/polygon-cli/releases/download/v${POLYCLI_TAG}/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz -O /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo chmod 0600 /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo tar -C /opt/ -xzf /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz
sudo ln -s /opt/polycli_${POLYCLI_TAG}_linux_amd64/polycli /usr/local/bin/polycli
rm -rf /opt/polycli_${POLYCLI_TAG}_linux_amd64.tar.gz