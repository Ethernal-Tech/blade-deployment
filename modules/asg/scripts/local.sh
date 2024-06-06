#!/bin/bash -x

main() {
    aws ssm get-parameter --region $REGION --name /$DEPLOYMENT_NAME/bootstrap.sh --query Parameter.Value --output text > /tmp/bootstrap.sh && \
    aws ssm get-parameter --region $REGION --name /$DEPLOYMENT_NAME/config.json  --query Parameter.Value --output text > /tmp/config.json 
    chmod +x /tmp/bootstrap.sh && \
    /tmp/bootstrap.sh
}

main