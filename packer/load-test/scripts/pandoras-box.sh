#!/bin/bash -e

##############
### NODEJS ###
##############
echo "Installing nodejs"
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install nodejs

############
### YARN ###
############
echo "Installing yarn"
sudo npm install --global yarn

####################
### PANDORAS-BOX ###
####################
echo "Installing pandoras-box"
sudo git clone --branch optimizations https://github.com/Ethernal-Tech/pandoras-box /opt/pandoras-box
cd /opt/pandoras-box && sudo yarn && sudo yarn build && sudo yarn link
sudo chmod 0777 /usr/local/bin/pandoras-box
sudo chown ubuntu:ubuntu /usr/local/bin/pandoras-box