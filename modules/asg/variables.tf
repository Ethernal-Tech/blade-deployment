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
variable "base_devnet_key_name" {
  description = "base key pair name to use for devnet"
  type        = string
}
variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}
variable "network_type" {
  description = "An identifier to indicate what type of network this is"
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

variable "geth_count" {
  description = "The number of geth nodes that we're going to deploy"
  type        = number
}

variable "node_storage" {
  description = "Size for the node storage"
}

variable "int_validator_alb_arn" {
  description = "Load balancer ARN"
}

variable "ext_validator_alb_arn" {
  description = "ARN for the application load balancer"

}

variable "ext_fullnode_alb_arn" {
  description = "ARN for the application load balancer"
}

variable "int_fullnode_alb_arn" {
  description = "Internal Load balancer ARN for"
}

variable "int_geth_alb_arn" {
  description = "Internal Load balancer ARN for geth"
}

variable "zones" {
  description = "List of availability zones"
}

variable "sg_all_node_id" {
  description = "Security group id for all nodes"

}
variable "sg_open_rpc_id" {
  description = "Open RPC Security group id for fullnodes/validators"

}

variable "sg_open_rpc_geth_id" {
  description = "Open RPC Security group id for geth"

}

variable "security_group_default_id" {
  description = "Default security group id"

}

variable "default_tags" {
  description = "A map of tags from the parent module"

}

variable "autoscale_handler_unique_identifier" {
  description = "asg_dns_handler"
  type        = string
  default     = "terminating"
}

variable "use_public_ip" {
  description = "Use public IP instead of private"
  default     = false
  type        = bool
}

variable "autoscale_route53zone_arn" {
  description = "The ARN of route53 zone associated with autoscaling group"
  type        = string
}

variable "autoscale_route53reverse_zone_arn" {
  description = "The ARN of route53 reverse zone associated with autoscaling group"
  type        = string
}

variable "route53_record_ttl" {
  description = "TTL to use for the Route 53 Records created"
  default     = 300
  type        = number
}

variable "private_zone_id" {
  description = "ID for the private DNS zone"

}

variable "reverse_zone_id" {
  description = "The ID of the reverse DNS zone"

}

variable "devnet_id" {
  description = "The ID of the VPC"
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

