#!/bin/bash -e
echo "Installing xk6"
go install go.k6.io/xk6/cmd/xk6@latest
sudo cp /root/go/bin/xk6 /usr/local/
sudo ln -s /usr/local/xk6 /usr/local/bin/xk6
