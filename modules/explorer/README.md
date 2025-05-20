Module used to deploy Blockscout

# Usage

```hcl
module "explorer" {
  source                 = "./modules/explorer"
  depends_on             = [module.asg]
  node_storage           = var.node_storage
  explorer_count         = var.explorer_count
  explorer_instance_type = var.base_instance_type

  deployment_name           = var.deployment_name
  zones                     = local.zones
  ec2_profile_name          = module.ssm.ec2_profile_name
  base_dn                   = local.base_dn
  private_network_mode      = var.private_network_mode
  private_subnet_ids        = module.networking.private_subnet_ids
  public_subnet_ids         = module.networking.public_subnet_ids
  devnet_key_name           = "${format("%s_ssh_key", var.deployment_name)}-${local.network_type}"
  sg_all_node_id            = module.securitygroups.security_group_all_node_instances_id
  sg_open_rpc_id            = module.securitygroups.security_group_open_rpc_id
  security_group_default_id = module.securitygroups.security_group_default_id
  region                    = var.region
  blockscout_db_password    = var.blockscout_db_password
  blade_jsonrpc_port        = 10002
  chain_id                  = var.chain_id
  explorer_target_group     = module.elb.tg_explorer_domain
}
```
