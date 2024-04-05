#!/bin/bash

parted /dev/nvme1n1 --script mklabel gpt mkpart primary ext4 0% 100%
sleep 5
mkfs.ext4 /dev/nvme1n1p1
sleep 5
partprobe /dev/nvme1n1p1
sleep 5
mkdir -p /var/lib/blade 
mount /dev/nvme1n1p1 /var/lib/blade
echo UUID=`(blkid /dev/nvme1n1p1 -s UUID -o value)` /var/lib/blade       ext4     defaults,nofail         1       2 >> /etc/fstab

chmod -R 777 /var/lib/blade

sleep 30

aws s3api wait object-exists \
    --bucket ${deployment_name}-state-bucket \
    --key ${deployment_name}.blade.ethernal.private.tar.gz

sleep 10

aws s3 cp s3://${deployment_name}-state-bucket/${deployment_name}.blade.ethernal.private.tar.gz /tmp/${deployment_name}.blade.ethernal.private.tar.gz
mkdir /var/lib/blade/bootstrap && chown blade /var/lib/blade/bootstrap && chgrp blade-group /var/lib/blade/bootstrap
tar -xf /tmp/${deployment_name}.blade.ethernal.private.tar.gz --directory /var/lib/blade/bootstrap

aws s3 cp s3://${deployment_name}-state-bucket/${hostname}.service /etc/systemd/system/blade.service
chmod 0644 /etc/systemd/system/blade.service
systemctl start blade

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
systemctl status amazon-cloudwatch-agent.service