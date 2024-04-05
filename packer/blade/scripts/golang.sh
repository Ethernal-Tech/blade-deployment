#!/bin/bash

echo Installig golang
sudo wget https://go.dev/dl/go$GOLANG_VERSION.tar.gz -O /opt/go$GOLANG_VERSION.tar.gz
sudo chmod 0755 /opt/go$GOLANG_VERSION.tar.gz
file /opt/go$GOLANG_VERSION.tar.gz
sudo tar -C /usr/local/ -xzf /opt/go$GOLANG_VERSION.tar.gz
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go