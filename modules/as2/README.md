EC2 module

Creates validators, fullnodes and testnodes. The instances run the user-data script that downloads all necesary configuration files and starts blade

USED: true
MANDATORY: true

## Usage

```hcl
module "asg" {
  source                    = "./modules/as2"
  depends_on                = [module.bootstrap, module.lambda]
  base_dn                   = local.base_dn
  base_instance_type        = var.base_instance_type
  fullnode_count            = var.fullnode_count
  geth_count                = var.geth_count
  validator_count           = var.validator_count
  private_network_mode      = var.private_network_mode
  deployment_name           = var.deployment_name
  create_ssh_key            = var.create_ssh_key
  devnet_key_value          = var.devnet_key_value
  private_subnet_ids        = module.networking.private_subnet_ids
  public_subnet_ids         = module.networking.public_subnet_ids
  ec2_profile_name          = module.ssm.ec2_profile_name
  zones                     = local.zones
  int_fullnode_alb_arn      = module.elb.tg_int_rpc_domain
  int_geth_alb_arn          = module.elb.tg_ext_rpc_geth_domain
  int_validator_alb_arn     = module.elb.tg_int_rpc_domain
  ext_validator_alb_arn     = module.elb.tg_ext_rpc_domain
  sg_all_node_id            = module.securitygroups.security_group_all_node_instances_id
  sg_open_rpc_id            = module.securitygroups.security_group_open_rpc_id
  sg_open_rpc_geth_id       = module.securitygroups.security_group_open_rpc_geth_id
  security_group_default_id = module.securitygroups.security_group_default_id
  default_tags              = local.default_tags
  private_zone_id           = module.dns.private_zone_id
  reverse_zone_id           = module.dns.reverse_zone_id
  devnet_key_name           = "${format("%s_ssh_key", var.deployment_name)}-${local.network_type}"
  sns_topic_arn             = module.lambda.sns_topic_arn
  lifecycle_role            = module.lambda.lifecycle_role
  node_storage              = var.node_storage
  region                    = var.region
  load_balancers = {
    for k, v in module.alb.lb_arns : v => var.lb_config[k]
  }
  validator_instance_type = var.validator_instance_type
  fullnode_instance_type  = var.fullnode_instance_type
}
```
