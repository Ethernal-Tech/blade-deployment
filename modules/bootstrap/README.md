Bootstrap module

Used for bootstraping the blockchain, executed on the local machine. Generates the keys and secrets for validators and fullnodes and generates the genesis file. Creates templated service and configuration files that are downloaded during runtime.

MANDATORY: true
USED: true

## Usage

```hcl
module "bootstrap" {
  source                = "./modules/bootstrap"
  validator_count       = var.validator_count
  fullnode_count        = var.fullnode_count
  deployment_name       = var.deployment_name
  base_dn               = local.base_dn
  default_tags          = local.default_tags
  region                = var.region
  epoch_reward          = var.epoch_reward
  block_gas_limit       = var.block_gas_limit
  max_enqueued          = var.max_enqueued
  max_slots             = var.max_slots
  block_time            = var.block_time
  is_bridge_active      = var.is_bridge_active
  is_london_fork_active = var.is_london_fork_active
  chain_id              = var.chain_id
  gossip_msg_size       = var.gossip_msg_size
  price_limit           = var.price_limit
  docker_image          = var.docker_image
  faucet_privkey        = var.faucet_privkey
  faucet_account        = var.faucet_account
  ec2_password          = var.ec2_password

}
```
