locals {
  network_type = "blade"
  base_ami     = "ami-0add1526ed372f405"
  geth_ami     = "ami-06d59880babda767d"
  base_dn      = format("%s.%s.%s.private", var.deployment_name, local.network_type, var.company_name)
  base_id      = format("%s-%s", var.deployment_name, local.network_type)
  default_tags = {
    Environment    = var.environment
    Network        = local.network_type
    Owner          = var.owner
    DeploymentName = var.deployment_name
    BaseDN         = local.base_dn
    Name           = local.base_dn
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
  fullnode_count         = var.fullnode_count
  validator_count        = var.validator_count
  geth_count             = var.geth_count
  route53_zone_id        = var.route53_zone_id
  deployment_name        = var.deployment_name
  devnet_id              = module.networking.devnet_id
  lb_int_rpc_domain      = module.elb.aws_lb_int_rpc_domain
  lb_ext_rpc_geth_domain = module.elb.aws_lb_ext_rpc_geth_domain
  lb_ext_rpc_domain      = module.elb.aws_lb_ext_rpc_domain
}

module "securitygroups" {
  source = "./modules/securitygroups"
  depends_on = [
    module.networking
  ]
  network_type       = local.network_type
  deployment_name    = var.deployment_name
  network_acl        = var.network_acl
  http_rpc_port      = var.http_rpc_port
  rootchain_rpc_port = var.rootchain_rpc_port

  devnet_id = module.networking.devnet_id
}

module "asg" {
  source                            = "./modules/asg"
  base_dn                           = local.base_dn
  base_instance_type                = var.base_instance_type
  base_ami                          = local.base_ami
  fullnode_count                    = var.fullnode_count
  geth_count                        = var.geth_count
  validator_count                   = var.validator_count
  base_devnet_key_name              = format("%s_ssh_key", var.deployment_name)
  private_network_mode              = var.private_network_mode
  network_type                      = local.network_type
  deployment_name                   = var.deployment_name
  create_ssh_key                    = var.create_ssh_key
  devnet_key_value                  = var.devnet_key_value
  node_storage                      = 100
  devnet_private_subnet_ids         = module.networking.devnet_private_subnet_ids
  devnet_public_subnet_ids          = module.networking.devnet_public_subnet_ids
  ec2_profile_name                  = module.ssm.ec2_profile_name
  zones                             = var.zones
  int_fullnode_alb_arn              = module.elb.tg_ext_rpc_domain
  int_geth_alb_arn                  = module.elb.tg_ext_rpc_geth_domain
  int_validator_alb_arn             = module.elb.tg_int_rpc_domain
  ext_fullnode_alb_arn              = module.elb.tg_ext_rpc_domain
  ext_validator_alb_arn             = module.elb.tg_ext_rpc_domain
  sg_all_node_id                    = module.securitygroups.security_group_all_node_instances_id
  sg_open_rpc_id                    = module.securitygroups.security_group_open_rpc_id
  sg_open_rpc_geth_id               = module.securitygroups.security_group_open_rpc_geth_id
  security_group_default_id         = module.securitygroups.security_group_default_id
  default_tags                      = local.default_tags
  geth_ami                          = local.geth_ami
  private_zone_id                   = module.dns.private_zone_id
  reverse_zone_id                   = module.dns.reverse_zone_id
  autoscale_route53reverse_zone_arn = module.dns.reverse_zone_arn
  autoscale_route53zone_arn         = module.dns.private_zone_arn
  devnet_id                         = module.networking.devnet_id
}

module "monitoring" {
  source                    = "./modules/monitoring"
  base_dn                   = local.base_dn
  sg_all_node_id            = module.securitygroups.security_group_all_node_instances_id
  sg_open_rpc_id            = module.securitygroups.security_group_open_rpc_id
  sg_open_rpc_geth_id       = module.securitygroups.security_group_open_rpc_geth_id
  security_group_default_id = module.securitygroups.security_group_default_id
  default_tags              = local.default_tags
  devnet_id                 = module.networking.devnet_id
  devnet_private_subnet_ids = module.networking.devnet_private_subnet_ids
  devnet_public_subnet_ids  = module.networking.devnet_public_subnet_ids
  network_type              = local.network_type
  deployment_name           = var.deployment_name
  devnet_key_pair_name      = module.asg.key_pair_name 
}

module "elb" {
  source                      = "./modules/elb"
  http_rpc_port               = var.http_rpc_port
  rootchain_rpc_port          = var.rootchain_rpc_port
  fullnode_count              = var.fullnode_count
  validator_count             = var.validator_count
  geth_count                  = var.geth_count
  route53_zone_id             = var.route53_zone_id
  base_id                     = local.base_id
  devnet_private_subnet_ids   = module.networking.devnet_private_subnet_ids
  devnet_public_subnet_ids    = module.networking.devnet_public_subnet_ids
  devnet_id                   = module.networking.devnet_id
  security_group_open_http_id = module.securitygroups.security_group_open_http_id
  security_group_default_id   = module.securitygroups.security_group_default_id
  certificate_arn             = module.dns.certificate_arn
}

module "networking" {
  source                = "./modules/networking"
  base_dn               = local.base_dn
  devnet_vpc_block      = var.devnet_vpc_block
  devnet_public_subnet  = var.devnet_public_subnet
  devnet_private_subnet = var.devnet_private_subnet
  zones                 = var.zones
}

module "ssm" {
  source          = "./modules/ssm"
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