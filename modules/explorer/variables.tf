variable "base_dn" {
  description = "Value of the base domain name to identify the resources"
  type        = string
}
variable "private_network_mode" {
  description = "True if vms should bey default run in the private subnets"
  type        = bool
}
variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "devnet_private_subnet_ids" {
  description = "Subnet IDs used in the private network"
  type        = list(string)
}
variable "devnet_public_subnet_ids" {
  description = "Subnet IDs used in the public network"
  type        = list(string)
}

variable "ec2_profile_name" {
  description = "TODO"
  type        = string
}


variable "explorer_count" {
  description = "The number of nodes to run as a blockchain explorer"
  type        = number
}

variable "explorer_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
}

variable "explorer_ami" {
  description = "Explorer AMI"
  type        = string
}

variable "region" {
  description = "Region to deploy in"
  type    = string
  default = "us-west-2"

}

variable "zones" {
  description = "Availability zones list"
  type = list(string)
}
variable "node_storage" {
  description = "Storage size for the EBS disj"
  type = number
}

variable "devnet_key_name" {
  type = string
  
}
variable "sg_all_node_id" {
  description = "Security group id for all nodes"
  type        = string

}
variable "sg_open_rpc_id" {
  description = "Open RPC Security group id for fullnodes/validators"
  type        = string

}
variable "security_group_default_id" {
  description = "Default security group id"
  type        = string

}