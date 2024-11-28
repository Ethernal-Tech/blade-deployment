variable "base_dn" {
  description = "Value of the base domain name to identify the resources"
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
variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "default_tags" {
  description = "A map of tags from the parent module"
  type        = object({})
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

variable "region" {
  type    = string
  default = "us-west-2"

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
