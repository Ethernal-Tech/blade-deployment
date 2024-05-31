variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
}

variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
}

variable "fullnode_count" {
  description = "The number of full nodes that we're going to deploy"
  type        = number
}

variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
}

variable "geth_count" {
  description = "The number of geth that we're going to deploy"
  type        = number
}

variable "devnet_private_subnet_ids" {
  type = list(string)
}

variable "devnet_public_subnet_ids" {
  type = list(string)
}

variable "fullnode_instance_ids" {
  type = list(string)
}

variable "validator_instance_ids" {
  type = list(string)
}

variable "geth_instance_ids" {
  type = list(string)
}

variable "devnet_id" {
  type = string
}

variable "base_id" {
  type = string
}

variable "security_group_open_http_id" {
  type = string
}

variable "security_group_default_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "certificate_explorer_arn" {
  type = string
}

variable "route53_zone_id" {
  description = "The ID for external DNS"
  type        = string
}

variable "explorer_count" {
  description = "The number of nodes to run as a blockchain explorer"
  type        = number
}

variable "explorer_instance_ids" {
  type = list(string)
}

variable "certificate_faucet_arn" {
  type = string
}
