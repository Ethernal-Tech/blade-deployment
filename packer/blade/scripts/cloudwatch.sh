#!/bin/bash

echo Installing cloudwatch agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

##TTODO
cp /tmp/cw_agent_config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json
cp /tmp/prometheus.yml /opt/aws/amazon-cloudwatch-agent/prometheus.yml
cp /tmp/prometheus_sd.yml /opt/aws/amazon-cloudwatch-agent/prometheus_sd.yml

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status