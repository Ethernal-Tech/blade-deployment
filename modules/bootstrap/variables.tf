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
}

variable "docker_image" {
  type    = string
  default = "0xethernal/blade:0.0.8"
}

variable "max_enqueued" {
  description = "The maximum number of enqueued transactions per account in the tx pool"
  type        = number
}

variable "max_slots" {
  description = "The maximum slots in the tx pool"
  type        = number
}

variable "block_gas_limit" {
  description = "The maximum amount of gas used by all transactions in a block"
  type        = number

}

variable "region" {
  type = string

}
variable "epoch_reward" {
  description = "The unit reward size for the block sealing"
  type        = number

}

variable "is_london_fork_active" {
  description = "Indication whether London hard fork (EIP-1559) is active"
  type        = bool

}

variable "is_bridge_active" {
  description = "Indication whether bridge should be deployed"
  type        = bool
}

variable "chain_id" {
  description = "The ID of the chain"
  type        = number

}

variable "block_time" {
  description = "The predefined period that determines block creation frequency"
  type        = number
}

variable "price_limit" {
  description = "the minimum gas price limit to enforce for acceptance into the pool"
  type        = number
}