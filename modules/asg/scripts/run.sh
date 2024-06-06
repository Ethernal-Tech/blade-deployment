#!/bin/bash

aws s3 cp s3://${DEPLOYMENT_NAME}-state-bucket/${BASE_DN}.tar.gz /tmp/${BASE_DN}.tar.gz && \
mkdir /var/lib/blade/bootstrap && chown blade /var/lib/blade/bootstrap && chgrp blade-group /var/lib/blade/bootstrap && \
tar -xf /tmp/${ BASE_DN }.tar.gz --directory /var/lib/blade/bootstrap 

aws ssm get-parameter --region ${REGION} --name /${DEPLOYMENT_NAME}/${HOSTNAME}.${BASE_DN}.service --query Parameter.Value --output text > /etc/systemd/system/blade.service && \
chmod 0644 /etc/systemd/system/blade.service && \
systemctl enable blade && \
systemctl start blade


sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/${DEPLOYMENT_NAME}/${HOSTNAME}/cw_agent_config
systemctl status amazon-cloudwatch-agent.service