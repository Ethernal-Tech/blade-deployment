#!/bin/bash

set -x

instance=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
snapshot=$(aws ec2 describe-snapshots --region ${region} --max-items 1 --filters 'Name=tag:Name,Values=${name}-volume-${base_dn}' --query "Snapshots[?(StartTime>='$(date --date='-1 day' '+%Y-%m-%d')')].{ID:SnapshotId}" --output text)
echo $snapshot

if [ -z "$snapshot"];
then
    aws ec2 attach-volume --volume-id ${volume} --instance-id $instance --device /dev/sdf --region ${region}
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

else
    EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    volume_id=$(aws ec2 create-volume --volume-type gp3  --snapshot-id $snapshot --availability-zone $EC2_AVAIL_ZONE --tag-specifications 'ResourceType=volume,Tags=[{Key=DeploymentName,Value=${deployment_name}},{Key=Name,Value=${name}-volume-${base_dn}}]'  --query "VolumeId" --region ${region} --output text)

    sleep 10
    aws ec2 attach-volume --volume-id $volume_id --instance-id $instance --device /dev/sdf --region ${region}

    aws ec2 modify-instance-attribute --instance-id $instance --block-device-mappings "[{\"DeviceName\": \"/dev/sdf\",\"Ebs\":{\"DeleteOnTermination\":true}}]" --region ${region}
    mkdir -p ${ blade_home_dir } 
    mount /dev/nvme1n1p1 ${ blade_home_dir }
fi




aws s3 cp s3://${deployment_name}-state-bucket/${ base_dn }.tar.gz /tmp/${ base_dn }.tar.gz && \
mkdir ${ blade_home_dir }/bootstrap && chown blade ${ blade_home_dir }/bootstrap && chgrp blade-group ${ blade_home_dir }/bootstrap && \
tar -xf /tmp/${ base_dn }.tar.gz --directory ${ blade_home_dir }/bootstrap 

chown -R blade:blade-group ${ blade_home_dir }/bootstrap

aws ssm get-parameter --region ${region} --name /${deployment_name}/${hostname}.service --query Parameter.Value --output text > /etc/systemd/system/blade.service && \
chmod 0644 /etc/systemd/system/blade.service 
sudo systemctl daemon-reload
sudo systemctl enable blade && \
sudo systemctl start blade


sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/${deployment_name}/${hostname}/cw_agent_config
systemctl status amazon-cloudwatch-agent.service

