import json
import logging
import boto3
import sys
import os
import time
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(logging.INFO)

config = Config(
    region_name = 'us-west-2'
)

autoscaling = boto3.client('autoscaling')
ec2 = boto3.client('ec2')
route53 = boto3.client('route53')
dynamodb = boto3.client('dynamodb')
ssm = boto3.client('ssm', config = config)

HOSTNAME_TAG_NAME = "asg:hostname_pattern"

LIFECYCLE_KEY = "LifecycleHookName"
ASG_KEY = "AutoScalingGroupName"



def find_value_not_in_use(message):
    instance = message['detail']['instance-id']
    details = {}
    for i in range(1,10):
        tags = ec2.describe_tags(
                Filters=[
                    {'Name': 'resource-id','Values': [instance]},
                    {'Name': 'key', 'Values':['Hostname']}
                ]
            )['Tags']
        details = tags[0] if len(tags) > 0 else {} 
        if len(tags) != 0 :
            break
        else:
            time.sleep(i*2)
    
    hostname = details.get('Value',None)
    if hostname:
        if message['detail']['state'] == 'running':           
            for i in range(1,10):
                try:
                    ssm.send_command(InstanceIds=[instance], DocumentName="AWS-RunShellScript", MaxErrors='10', Parameters={
                        'commands':[
                            'sudo /etc/blade/run.sh | sudo tee /etc/blade/runner_output.txt'
                            ]
                            }
                        )
                    break
                except Exception as e:
                    print('Command not sent')
                    time.sleep(i*2)
        elif message['detail']['state'] == 'shutting-down':
            
                tag = hostname.split('.')[0]
                dynamodb.update_item( TableName='Hostnames', ConditionExpression="#EX = :used",
                                            ExpressionAttributeValues={':used': {'BOOL': True}, ':unused': {'BOOL': False}},
                                            ExpressionAttributeNames={'#EX': 'Exists'},
                                            Key={
                                                'Hostname' : {
                                                    'S': tag,
                                                    },
                                                                },
                                            UpdateExpression="SET #EX = :unused"
                                            )

# Processes a scaling event
# Builds a hostname from tag metadata, fetches a IP, and updates records accordingly
def process_message(message):
    find_value_not_in_use(message)

# Picks out the message from a SNS message and deserializes it
def process_record(record):
    process_message(json.loads(record['Sns']['Message']))

# Main handler where the SNS events end up to
# Events are bulked up, so process each Record individually
def lambda_handler(event, context):
    logger.info("Processing SNS event: " + json.dumps(event))

    for record in event['Records']:
        process_record(record)

# if invoked manually, assume someone pipes in a event json
if __name__ == "__main__":
    logging.basicConfig()

    lambda_handler(json.load(sys.stdin), None)