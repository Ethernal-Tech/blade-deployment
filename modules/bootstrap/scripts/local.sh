#!/bin/bash -x

main() {
    aws s3 cp s3://$DEPLOYMENT_NAME-state-bucket/$DEPLOYMENT_NAME/bootstrap.sh /tmp/bootstrap.sh && \
    aws ssm get-parameter --region $REGION --name /$DEPLOYMENT_NAME/config.json  --query Parameter.Value --output text > /tmp/config.json 
    chmod +x /tmp/bootstrap.sh && \
    /tmp/bootstrap.sh
}

main