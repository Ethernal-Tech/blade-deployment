# About

Module creates and setups monitoring for the network Creates and additional instance that uses service discovery to scrape prometheus metrics and pushes them to the prometheus endpoint. Grafana then collects the data from that endpoint

# Usage

```hcl
module "monitoring" {
  source                    = "./modules/monitoring"
  base_dn                   = local.base_dn
  sg_all_node_id            = module.securitygroups.security_group_all_node_instances_id
  sg_open_rpc_id            = module.securitygroups.security_group_open_rpc_id
  security_group_default_id = module.securitygroups.security_group_default_id
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  network_type              = local.network_type
  deployment_name           = var.deployment_name
  region                    = var.region
}
```
