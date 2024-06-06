#!/bin/bash

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
hostname=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Hostname)
deplyment=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/DeploymentName)

echo ${hostname}

# aws s3 cp s3://${deplyment}-state-bucket/${basedn}.tar.gz /tmp/${basedn}.tar.gz && \
# mkdir /var/lib/blade/bootstrap && chown blade /var/lib/blade/bootstrap && chgrp blade-group /var/lib/blade/bootstrap && \
# tar -xf /tmp/${basedn}.tar.gz --directory /var/lib/blade/bootstrap 

aws ssm get-parameter --region us-west-2 --name /${deplyment}/${hostname}.service --query Parameter.Value --output text > /etc/systemd/system/blade.service && \
chmod 0644 /etc/systemd/system/blade.service && \
sudo systemctl enable blade && \
sudo systemctl start blade


sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/${deplyment}/${hostname}/cw_agent_config
systemctl status amazon-cloudwatch-agent.service