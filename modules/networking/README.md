# About

Module creates a VPC with 4 subnets, 2 are public, two are private, attaches an internet gateway and defines the route tables

## Usage

```hcl
module "networking" {
  source                = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/networking?ref=v1.0.3"
  base_dn               = local.base_dn
  devnet_vpc_block      = var.devnet_vpc_block
  devnet_public_subnet  = var.devnet_public_subnet
  devnet_private_subnet = var.devnet_private_subnet
  zones                 = local.zones
}
```
