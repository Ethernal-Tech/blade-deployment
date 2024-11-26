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
  type    = number
  default = 67108864
}

variable "docker_image" {
  type    = string
  default = "0xethernal/blade:0.0.8"
}

variable "max_enqueued" {
  type    = number
  default = 20000000
}

variable "max_slots" {
  type    = number
  default = 20000000
}

variable "block_gas_limit" {
  type    = number
  default = 50000000

}

variable "region" {
  type    = string
  default = "us-west-2"

}
variable "epoch_reward" {
  type    = number
  default = 1000000000

}

variable "is_london_fork_active" {
  default = false
  type    = bool

}

variable "is_bridge_active" {
  default = false
  type    = bool
}

variable "chain_id" {
  type    = number
  default = 100

}

variable "block_time" {
  type    = number
  default = 1
}
