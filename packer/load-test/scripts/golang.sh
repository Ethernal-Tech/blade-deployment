#!/bin/bash -e
echo "Installing golang"
rm -rf /usr/local/go
sudo wget https://go.dev/dl/go${GO_TAG}.tar.gz -O /opt/go${GO_TAG}.tar.gz
sudo chmod 0755 /opt/go${GO_TAG}.tar.gz
sudo tar -C /usr/local/ -xzf /opt/go${GO_TAG}.tar.gz
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
sudo rm -rf /opt/go${GO_TAG}.tar.gz
