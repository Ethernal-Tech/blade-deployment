#!/bin/bash

set -x

instance=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

if [ ! -f /etc/blade/.disk_parted ];
then
    aws ec2 attach-volume --volume-id ${volume} --instance-id $instance --device /dev/sdf --region us-west-2
    sleep 5
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



# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/${deployment_name}/${hostname}/cw_agent_config
# systemctl status amazon-cloudwatch-agent.service
