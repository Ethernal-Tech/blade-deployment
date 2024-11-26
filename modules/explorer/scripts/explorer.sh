#!/bin/bash

set -x

instance=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
snapshot=$(aws ec2 describe-snapshots --region us-west-2 --max-items 1 --filters 'Name=tag:Name,Values=${name}-volume-${base_dn}' --query "Snapshots[?(StartTime>='$(date --date='-1 day' '+%Y-%m-%d')')].{ID:SnapshotId}" --output text)
echo $snapshot

if [ -z "$snapshot"];
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

else
    EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    volume_id=$(aws ec2 create-volume --volume-type gp3  --snapshot-id $snapshot --availability-zone $EC2_AVAIL_ZONE --tag-specifications 'ResourceType=volume,Tags=[{Key=DeploymentName,Value=mmnet},{Key=Name,Value=${name}-volume-${base_dn}}}]'  --query "VolumeId" --region us-west-2 --output text)

    sleep 10
    aws ec2 attach-volume --volume-id $volume_id --instance-id $instance --device /dev/sdf --region us-west-2

    aws ec2 modify-instance-attribute --instance-id $instance --block-device-mappings "[{\"DeviceName\": \"/dev/sdf\",\"Ebs\":{\"DeleteOnTermination\":true}}]" --region us-west-2
    mkdir -p ${ blade_home_dir } 
    mount /dev/nvme1n1p1 ${ blade_home_dir }
fi

aws ssm get-parameter --region ${region} --name /${deployment_name}/explorer.env --query Parameter.Value --output text > ${blade_home_dir}/explorer.env && \
aws ssm get-parameter --region ${region} --name /${deployment_name}/contract-verifier.toml --query Parameter.Value --output text > ${blade_home_dir}/contract-verifier.toml


pushd /opt/blockscout

git clone https://github.com/Ethernal-Tech/blockscout
pushd blockscout/docker-compose
docker compose up -d
popd

popd
