# About

This modules defines the IAM role and policy to be attached to on EC2 instances

## Usage

```hcl
module "ssm" {
  source          = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/ssm?ref=v1.0.3"
  base_dn         = local.base_dn
  deployment_name = var.deployment_name
  network_type    = local.network_type
}
```
