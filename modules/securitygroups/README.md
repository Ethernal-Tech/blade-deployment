# About

Module defines security groups and rules to be applied to the instances and VPC

## Usage
```hcl
module "securitygroups" {
  source = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/securitygroups?ref=v1.0.3"
  depends_on = [
    module.networking
  ]
  network_type       = local.network_type
  deployment_name    = var.deployment_name
  network_acl        = var.network_acl
  http_rpc_port      = var.http_rpc_port
  rootchain_rpc_port = var.rootchain_rpc_port
  vpc_id             = module.networking.vpc_id
}
```
