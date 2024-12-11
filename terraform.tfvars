deployment_name    = "mmnet"
route53_zone_id    = "Z09646524EXRI77FQSQC"
fullnode_count     = 4
validator_count    = 4
explorer_count     = 0
base_instance_type = "c6a.xlarge"
create_ssh_key     = true
node_storage       = 50
region             = "us-west-1"
lb_config = {
  api  = [0, 2]
  test = [1, 3]
}
