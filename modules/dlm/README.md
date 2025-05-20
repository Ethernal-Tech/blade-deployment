Module that creates the Data lifecycle manager used for creating disk snapshots. Not used at the moment

MANDATORY: false
USED: false

## Usage

```hcl
module "dlm" {

  source          = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/dlm?ref=v1.0.3"
  base_dn         = local.base_dn
  deployment_name = var.deployment_name

 }
 ```
