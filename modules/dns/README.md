Private and public DNS records and zones

MANDATORY: true
USED: yes

## Usage

```hcl
module "dns" {
  source                 = "./modules/dns"
  base_dn                = local.base_dn
  region                 = var.region
  route53_zone_id        = var.route53_zone_id
  deployment_name        = var.deployment_name
  vpc_id                 = module.networking.vpc_id
  lb_int_rpc_domain      = module.elb.aws_lb_int_rpc_domain
  lb_ext_rpc_geth_domain = module.elb.aws_lb_ext_rpc_geth_domain
  lb_ext_rpc_domain      = module.elb.aws_lb_ext_rpc_domain
  lb_explorer            = module.elb.lb_explorer
}
```
