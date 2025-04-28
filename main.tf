locals {
  network_type = "blade"

  base_dn = format("%s.%s.%s.private", var.deployment_name, local.network_type, var.company_name)
  base_id = format("%s-%s", var.deployment_name, local.network_type)
  default_tags = {
    Environment    = var.environment
    Network        = local.network_type
    Owner          = var.owner
    DeploymentName = var.deployment_name
    BaseDN         = local.base_dn
    Name           = local.base_dn
  }
  zones = data.aws_availability_zones.zones.names
}

data "aws_availability_zones" "zones" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}
terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36.0"
    }
  }
  required_version = ">= 1.4.0"
}

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
  access_key_id         = var.access_key_id
  secret_access_key     = var.secret_access_key
  docker_image          = var.docker_image
  faucet_privkey        = var.faucet_privkey
  faucet_account        = var.faucet_account

}

module "lambda" {
  source                              = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/lambda?ref=v1.0.3"
  autoscale_handler_unique_identifier = "launching"
  autoscale_route53zone_arn           = module.dns.private_zone_arn
  autoscale_route53reverse_zone_arn   = module.dns.reverse_zone_arn
  deployment_name                     = var.deployment_name
}

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
# module "dlm" {

#   source          = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/dlm?ref=v1.0.3"
#   base_dn         = local.base_dn
#   deployment_name = var.deployment_name

# }

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

module "elb" {
  source                      = "./modules/elb"
  http_rpc_port               = var.http_rpc_port
  rootchain_rpc_port          = var.rootchain_rpc_port
  base_id                     = local.base_id
  private_subnet_ids          = module.networking.private_subnet_ids
  public_subnet_ids           = module.networking.public_subnet_ids
  vpc_id                      = module.networking.vpc_id
  security_group_open_http_id = module.securitygroups.security_group_open_http_id
  security_group_default_id   = module.securitygroups.security_group_default_id
  certificate_arn             = module.dns.certificate_arn
  certificate_explorer_arn    = module.dns.certificate_explorer_arn


}

module "networking" {
  source                = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/networking?ref=v1.0.3"
  base_dn               = local.base_dn
  devnet_vpc_block      = var.devnet_vpc_block
  devnet_public_subnet  = var.devnet_public_subnet
  devnet_private_subnet = var.devnet_private_subnet
  zones                 = local.zones
}

module "ssm" {
  source          = "git@github.com:Ethernal-Tech/blade-deployment.git//modules/ssm?ref=v1.0.3"
  base_dn         = local.base_dn
  deployment_name = var.deployment_name
  network_type    = local.network_type
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment    = var.environment
      Network        = local.network_type
      Owner          = var.owner
      DeploymentName = var.deployment_name
      BaseDN         = local.base_dn
      Name           = local.base_dn
    }
  }
}
