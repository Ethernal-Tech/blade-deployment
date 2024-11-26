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
  description = "value"
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
}

variable "region" {
  type    = string
  default = "us-west-2"

}

variable "zones" {

}
variable "node_storage" {

}

