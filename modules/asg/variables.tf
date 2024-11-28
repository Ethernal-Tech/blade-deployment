variable "base_dn" {
  description = "Value of the base domain name to identify the resources"
  type        = string
}
variable "base_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
}
variable "base_ami" {
  description = "Value of the base AMI that we're using"
  type        = string
}
variable "geth_ami" {
  description = "Value of the base AMI that we're using"
  type        = string
}
variable "fullnode_count" {
  description = "The number of full nodes that we're going to deploy"
  type        = number
}
variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
}
variable "private_network_mode" {
  description = "True if vms should bey default run in the private subnets"
  type        = bool
}

variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "create_ssh_key" {
  description = "Should a new ssh key be created or should we use the devnet_key_value"
  type        = bool
}
variable "devnet_key_value" {
  description = "The public key value to use for the ssh key"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs used in the private network"
  type        = list(string)
}
variable "public_subnet_ids" {
  description = "Subnet IDs used in the public network"
  type        = list(string)
}

variable "ec2_profile_name" {
  description = "TODO"
  type        = string
}

variable "geth_count" {
  description = "The number of geth nodes that we're going to deploy"
  type        = number
}


variable "int_validator_alb_arn" {
  description = "Load balancer ARN"
  type        = string
}

variable "ext_validator_alb_arn" {
  description = "ARN for the application load balancer"
  type        = string

}

variable "int_fullnode_alb_arn" {
  description = "Internal Load balancer ARN for"
  type        = string
}

variable "int_geth_alb_arn" {
  description = "Internal Load balancer ARN for geth"
  type        = string
}

variable "zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "sg_all_node_id" {
  description = "Security group id for all nodes"
  type        = string

}
variable "sg_open_rpc_id" {
  description = "Open RPC Security group id for fullnodes/validators"
  type        = string

}
variable "sg_open_rpc_geth_id" {
  description = "Open RPC Security group id for geth"
  type        = string

}
variable "security_group_default_id" {
  description = "Default security group id"
  type        = string

}
variable "default_tags" {
  description = "A map of tags from the parent module"
  type        = object({})

}
variable "private_zone_id" {
  description = "ID for the private DNS zone"
  type        = string
}

variable "reverse_zone_id" {
  description = "The ID of the reverse DNS zone"
  type        = string
}

variable "region" {
  type    = string
  default = "us-west-2"

}

variable "blade_home_dir" {
  type    = string
  default = "/var/lib/blade"

}

variable "devnet_key_name" {
  description = "Name for the ssh key"
  type        = string

}

variable "lifecycle_role" {
  description = "ARN for the role used for the lifecycle hook"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic for autoscaling lifecycle hook"
  type        = string
}

variable "node_storage" {
  description = "Disk size for the external EBS volume"
  type        = number
}