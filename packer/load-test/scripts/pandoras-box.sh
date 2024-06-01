#!/bin/bash -e
echo "Installing pandoras-box"
sudo git clone --branch optimizations https://github.com/Ethernal-Tech/pandoras-box /opt/pandoras-box
cd /opt/pandoras-box && sudo yarn && sudo yarn build && sudo yarn link
sudo chmod 0777 /usr/local/bin/pandoras-box
sudo chown ubuntu:ubuntu /usr/local/bin/pandoras-box
