#!/bin/bash -e

##########
### K6 ###
##########
echo "Installing k6"
gpg -k
gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install k6

###########
### XK6 ###
###########
echo "Installing xk6"
go install go.k6.io/xk6/cmd/xk6@latest
sudo cp /root/go/bin/xk6 /usr/local/
sudo ln -s /usr/local/xk6 /usr/local/bin/xk6

####################
### XK6-ETHEREUM ###
####################
echo "Building xk6-ethereum"
xk6 build --with github.com/distribworks/xk6-ethereum@v1.0.3 --output /home/ubuntu/k6