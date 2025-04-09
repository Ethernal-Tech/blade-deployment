#!/bin/bash

set -x

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


aws ssm get-parameter --region ${region} --name /${deployment_name}/blockscout.env --query Parameter.Value --output text > ${blade_home_dir}/blockscout.env && \


pushd /opt/blockscout

git clone https://github.com/Ethernal-Tech/blockscout
pushd blockscout/docker-compose
docker compose up -d
popd

popd
