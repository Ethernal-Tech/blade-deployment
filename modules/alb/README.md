This module defines scope based application load balancers. The load balancer listens on HTTP and HTTPS port.

MANDATORY: false
USED: false

```hcl
module "alb" {
  source                      = "./modules/alb"
  http_rpc_port               = var.http_rpc_port
  base_id                     = local.base_id
  public_subnet_ids           = module.networking.public_subnet_ids
  vpc_id                      = module.networking.vpc_id
  security_group_open_http_id = module.securitygroups.security_group_open_http_id
  security_group_default_id   = module.securitygroups.security_group_default_id
  names                       = toset(keys(var.lb_config))
}
```
