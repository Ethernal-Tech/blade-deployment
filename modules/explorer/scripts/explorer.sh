#!/bin/bash

set -x

aws ssm get-parameter --region ${region} --name /${deployment_name}/explorer.env --query Parameter.Value --output text > ${blade_home_dir}/explorer.env && \
aws ssm get-parameter --region ${region} --name /${deployment_name}/contract-verifier.toml --query Parameter.Value --output text > ${blade_home_dir}/contract-verifier.toml


pushd /opt/blockscout

git clone https://github.com/Ethernal-Tech/blockscout
pushd blockscout/docker-compose
docker compose up -d
popd

popd
