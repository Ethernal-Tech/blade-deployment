import json
import logging
import boto3
import sys
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

autoscaling = boto3.client('autoscaling')
ec2 = boto3.client('ec2')
route53 = boto3.client('route53')
dynamodb = boto3.client('dynamodb')
ssm = boto3.client('ssm')

HOSTNAME_TAG_NAME = "asg:hostname_pattern"

LIFECYCLE_KEY = "LifecycleHookName"
ASG_KEY = "AutoScalingGroupName"


def fetch_ip_from_ec2(instance_id):
    logger.info("Fetching IP for instance-id: %s", instance_id)
    ec2_response = ec2.describe_instances(InstanceIds=[instance_id])
    logger.info(ec2_response)
    if 'USE_PUBLIC_IP' in os.environ and os.environ['USE_PUBLIC_IP'] == "true":
        ip_address = ec2_response['Reservations'][0]['Instances'][0].get('PublicIpAddress',"")
        logger.info("Found public IP for instance-id %s: %s", instance_id, ip_address)
    else:
        ip_address = ec2_response['Reservations'][0]['Instances'][0].get('PrivateIpAddress',"")
        logger.info("Found private IP for instance-id %s: %s", instance_id, ip_address)

    return ip_address

def fetch_tag_metadata(asg_name):
    logger.info("Fetching tags for ASG: %s", asg_name)

    tag_value = autoscaling.describe_tags(
        Filters=[
            {'Name': 'auto-scaling-group','Values': [asg_name]},
            {'Name': 'key','Values': [HOSTNAME_TAG_NAME]}
        ],
        MaxRecords=1
    )['Tags'][0]['Value']

    logger.info("Found tags for ASG %s: %s", asg_name, tag_value)

    return tag_value.split("@")

# Updates a Route53 record
def update_record(zone_id, ip, hostname, operation, reverse=False):
    logger.info("Changing record with %s for %s -> %s in %s", operation, hostname, ip, zone_id)
    pi = ip.split('.')
    pi.reverse()
    route53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Changes': [
                {
                    'Action': operation,
                    'ResourceRecordSet': {
                        'Name': ".".join(pi) + ".in-addr.arpa" if reverse else hostname,
                        'Type': 'PTR' if reverse else 'A',
                        'TTL': int(os.environ['ROUTE53_TTL']),
                        'ResourceRecords': [{'Value': hostname if reverse else ip}]
                    }
                }
            ]
        }
    )

def find_value_not_in_use(message):
    instance = message['EC2InstanceId']
    updating = True
    while updating:
        for i in range(1,5):
            try: 
                query = dynamodb.update_item( TableName='Hostnames', ConditionExpression="#EX = :unused",
                                    ExpressionAttributeValues={':used': {'BOOL': True}, ':unused': {'BOOL': False}},
                                    ExpressionAttributeNames={'#EX': 'Exists'},
                                    Key={
                                        'Hostname' : {
                                            'S': "validator-00{}".format(i),
                                            },
                                                        },
                                    UpdateExpression="SET #EX = :used"
                
                                )
            except dynamodb.exceptions.ConditionalCheckFailedException:
                print('key in use')
                continue
            else:
                ip = fetch_ip_from_ec2(instance)
                asg_name = message['AutoScalingGroupName']
                hostname_pattern, zone_id, reverse_zone_id= fetch_tag_metadata(asg_name)
                hostname = "validator-00{}.{}".format(i,hostname_pattern)
                ec2.create_tags(Resources=[instance], Tags=[{'Key': 'Name', 'Value': hostname},{'Key': 'Hostname', 'Value': hostname}])
                update_record(zone_id, ip, hostname, 'UPSERT')
                update_record(reverse_zone_id, ip, hostname, 'UPSERT', reverse=True)
                    
                updating = False
                print(query)
                break
         



# Processes a scaling event
# Builds a hostname from tag metadata, fetches a IP, and updates records accordingly
def process_message(message):
    if message['Destination'] == "AutoScalingGroup":
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

    logger.info("Finishing ASG action")
    message =json.loads(record['Sns']['Message'])
    if LIFECYCLE_KEY in message and ASG_KEY in message :
        response = autoscaling.complete_lifecycle_action (
            LifecycleHookName = message['LifecycleHookName'],
            AutoScalingGroupName = message['AutoScalingGroupName'],
            InstanceId = message['EC2InstanceId'],
            LifecycleActionToken = message['LifecycleActionToken'],
            LifecycleActionResult = 'CONTINUE'

        )
        logger.info("ASG action complete: %s", response)
    else :
        logger.error("No valid JSON message")

# if invoked manually, assume someone pipes in a event json
if __name__ == "__main__":
    logging.basicConfig()

    lambda_handler(json.load(sys.stdin), None)