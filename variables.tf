
variable "base_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
  default     = "c6a.2xlarge"
}

variable "company_name" {
  description = "The name of the company for this particular deployment"
  type        = string
  default     = "ethernal"
}

variable "create_ssh_key" {
  description = "Should a new ssh key be created or should we use the devnet_key_value"
  type        = bool
  default     = true
}

variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
  default     = "devnet"
}

variable "devnet_key_value" {
  description = "The public key value to use for the ssh key. Required when create_ssh_key is false"
  type        = string
  default     = ""
}

variable "devnet_private_subnet" {
  description = "The cidr block for the private subnet in our VPC"
  type        = list(string)
  default     = ["10.10.64.0/22", "10.10.68.0/22", "10.10.72.0/22", "10.10.76.0/22"]
}

variable "devnet_public_subnet" {
  description = "The cidr block for the public subnet in our VPC"
  type        = list(string)
  default     = ["10.10.0.0/22", "10.10.4.0/22", "10.10.8.0/22", "10.10.12.0/22"]
}

variable "devnet_vpc_block" {
  description = "The cidr block for our VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "environment" {
  description = "The environment for deployment for this particular deployment"
  type        = string
  default     = "devnet"
}

variable "fullnode_count" {
  description = "The number of full nodes that we're going to deploy"
  type        = number
  default     = 0
}

variable "geth_count" {
  description = "The number of geth nodes that we're going to deploy"
  type        = number
  default     = 0
  validation {
    condition = (
      var.geth_count == 0 || var.geth_count == 1
    )
    error_message = "There should only be 1 geth node, or none (if you are using another public L1 chain for bridge)."
  }
}

variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
  default     = 10002
}

variable "network_acl" {
  description = "Which CIDRs should be allowed to access the explorer and RPC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_storage" {
  description = "The size of the storage disk attached to full nodes and validators"
  type        = number
  default     = 10
}

variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
  default     = 8545
}

variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain the CNAME record to our LB"
  type        = string
  default     = ""
}

variable "owner" {
  description = "The main point of contact for this particular deployment"
  type        = string
  default     = "user@email.com"
}

variable "private_network_mode" {
  description = "True if vms should bey default run in the private subnets"
  type        = bool
  default     = true
}

variable "region" {
  description = "The region where we want to deploy"
  type        = string
  default     = "us-west-2"
}

variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
  default     = 4
  validation {
    condition = (
      var.validator_count >= 4
    )
    error_message = "Minimum 4 validators!"
  }
}

variable "explorer_count" {
  description = "The number of nodes to run as a blockchain explorer"
  type        = number
  default     = 1
}


variable "gossip_msg_size" {
  description = "The maximum size of a gossip message"
  type        = number
  default     = 67108864
}

variable "docker_image" {
  type    = string
  default = "0xethernal/blade:0.0.8"
}

variable "max_enqueued" {
  description = "The maximum number of enqueued transactions per account in the tx pool"
  type        = number
  default     = 20000000
}

variable "max_slots" {
  description = "The maximum slots in the tx pool"
  type        = number
  default     = 20000000
}

variable "block_gas_limit" {
  description = "The maximum amount of gas used by all transactions in a block"
  type        = number
  default     = 50000000

}

variable "epoch_reward" {
  description = "The unit reward size for the block sealing"
  type        = number
  default     = 1000000000

}

variable "is_london_fork_active" {
  description = "Indication whether London hard fork (EIP-1559) is active"
  default     = false
  type        = bool

}

variable "is_bridge_active" {
  description = "Indication whether bridge should be deployed"
  default     = false
  type        = bool
}

variable "chain_id" {
  description = "The ID of the chain"
  type        = number
  default     = 100

}

variable "block_time" {
  description = "The predefined period that determines block creation frequency"
  type        = number
  default     = 1
}

variable "price_limit" {
  description = "the minimum gas price limit to enforce for acceptance into the pool"
  type        = number
  default     = 0
}

variable "lb_config" {
  type = map(list(number))

}


variable "access_key_id" {
  type      = string
  sensitive = false

}

variable "secret_access_key" {
  type      = string
  sensitive = false

}

variable "validator_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
  default     = "c6a.2xlarge"
}
variable "fullnode_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
  default     = "c6a.2xlarge"
}
