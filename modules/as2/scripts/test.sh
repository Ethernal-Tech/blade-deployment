#!/bin/bash

set -x

instance=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

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


pushd ${ blade_home_dir }

mkdir logs && chmod 755 logs

wget https://github.com/Ethernal-Tech/blade/releases/download/v${blade_version}/blade_${blade_version}_linux_amd64.tar.gz && tar -xvzf blade_${blade_version}_linux_amd64.tar.gz && chmod +x blade && cp blade /usr/local/bin/blade



aws s3 cp s3://${deployment_name}-state-bucket/${ base_dn }.tar.gz /tmp/${ base_dn }.tar.gz && \
mkdir ${ blade_home_dir }/bootstrap && chown blade ${ blade_home_dir }/bootstrap && chgrp blade-group ${ blade_home_dir }/bootstrap && \
tar -xf /tmp/${ base_dn }.tar.gz --directory ${ blade_home_dir }/bootstrap

chown -R blade:blade-group ${ blade_home_dir }/bootstrap

pushd bootstrap
aws ssm get-parameter --region ${region} --name /${deployment_name}/config.json  --query Parameter.Value --output text > ./config.json
sed 's/host/fullnode_test/g' ./config.json > secrets/fullnode_test_config.json
blade secrets init --config secrets/fullnode_test_config.json --json > fullnode_test.json

aws ssm get-parameter --region ${region} --name /${deployment_name}/fullnode_test.service --query Parameter.Value --output text > /etc/systemd/system/blade.service && \
chmod 0644 /etc/systemd/system/blade.service
sudo systemctl daemon-reload
sudo systemctl enable blade

cat > /etc/logrotate.d/blade.conf << EOF
${ blade_home_dir }/logs/*.log
{
        maxsize 1G
        daily
        missingok
        rotate 14
        notifempty
        compress
        delaycompress
}
EOF

chmod 0644 /etc/logrotate.d/blade.conf
logrotate -d /etc/logrotate.d/blade.conf

systemctl daemon-reload
systemctl enable logrotate.timer
systemctl restart logrotate.timer
