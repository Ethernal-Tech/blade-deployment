#!/bin/bash -e
echo "Building xk6-ethereum"
xk6 build --with github.com/distribworks/xk6-ethereum@v1.0.3 --output /home/ubuntu/k6
