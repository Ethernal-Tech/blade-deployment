#!/bin/bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
cd node_exporter-1.7.0.linux-amd64
sudo cp node_exporter /usr/local/bin
sudo useradd node_exporter -u 1003 --no-create-home --shell /bin/false
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo cp /tmp/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter