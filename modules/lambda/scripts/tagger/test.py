
import logging
import boto3



logger = logging.getLogger()
logger.setLevel(logging.INFO)

autoscaling = boto3.client('autoscaling')
ec2 = boto3.client('ec2')
route53 = boto3.client('route53')
dynamodb = boto3.client('dynamodb',region_name='us-west-2')
ssm = boto3.client('ssm',region_name='us-west-2')

HOSTNAME_TAG_NAME = "asg:hostname_pattern"

LIFECYCLE_KEY = "LifecycleHookName"
ASG_KEY = "AutoScalingGroupName"

def test():
    instance = "i-0409400bd86a087c2"
    response = ssm.send_command(InstanceIds=[instance], DocumentName="AWS-RunShellScript", Parameters={
                    'commands':[
                        'DEPLOYMENT_NAME={} BASE_DN={} HOSTNAME={} REGION={} sudo /etc/blade/run.sh'.format('xnet','xnet.blade.ethernal.private','validator-001','us-west-2')
                        ]
                        }
                    )
    command_id = response['Command']['CommandId']
    output = ssm.get_command_invocation(
        CommandId=command_id,
        InstanceId=instance,
        )
    print(output)
   
test()