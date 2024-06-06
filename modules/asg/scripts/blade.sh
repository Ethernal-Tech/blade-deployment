#!/bin/bash

if [ ! -f /etc/blade/.disk_parted ];
then
    parted /dev/nvme1n1 --script mklabel gpt mkpart primary ext4 0% 100%
    sleep 5
    mkfs.ext4 /dev/nvme1n1p1
    sleep 5
    partprobe /dev/nvme1n1p1
    sleep 5
    mkdir -p ${ blade_home_dir } 
    mount /dev/nvme1n1p1 ${ blade_home_dir }
    echo UUID=`(blkid /dev/nvme1n1p1 -s UUID -o value)` ${ blade_home_dir }       ext4     defaults,nofail         1       2 >> /etc/fstab

    chmod -R 777 ${ blade_home_dir }
    touch /etc/blade/.disk_parted

    sleep 30
fi


aws s3 cp s3://${deployment_name}-state-bucket/${ base_dn }.tar.gz /tmp/${ base_dn }.tar.gz && \
mkdir ${ blade_home_dir }/bootstrap && chown blade ${ blade_home_dir }/bootstrap && chgrp blade-group ${ blade_home_dir }/bootstrap && \
tar -xf /tmp/${ base_dn }.tar.gz --directory ${ blade_home_dir }/bootstrap 

chown -R blade:blade-group ${ blade_home_dir }/bootstrap

# aws ssm get-parameter --region ${region} --name /${deployment_name}/${hostname}.${base_dn}.service --query Parameter.Value --output text > /etc/systemd/system/blade.service && \
# chmod 0644 /etc/systemd/system/blade.service && \
# systemctl enable blade && \
# systemctl start blade


# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/${deployment_name}/${hostname}/cw_agent_config
# systemctl status amazon-cloudwatch-agent.service

# sudo systemctl status amazon-ssm-agent