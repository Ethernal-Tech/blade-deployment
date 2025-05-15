#!/bin/bash -x

main() {
    pushd /tmp
    mkdir $RANDOM_PET
    pushd $RANDOM_PET
    aws s3 cp s3://$DEPLOYMENT_NAME-state-bucket/$DEPLOYMENT_NAME/bootstrap.sh ./bootstrap.sh && \
    aws ssm get-parameter --region $REGION --name /$DEPLOYMENT_NAME/config.json  --query Parameter.Value --output text > ./config.json
    chmod +x ./bootstrap.sh && \
    ./bootstrap.sh > ./bootstrap_output.txt 2>&1
    popd
    popd
}

main
