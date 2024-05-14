variable "base_dn" {
  description = "Value of the base domain name to identify the resources"
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

variable "devnet_private_subnet_ids" {
  description = "Subnet IDs used in the private network"
  type = list(string)
}
variable "devnet_public_subnet_ids" {
   description = "Subnet IDs used in the public network"
  type = list(string)
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

variable "devnet_id" {
  description = "The ID of the VPC"
  type        = string

}

variable "node_exporter_port" {
    description = "Node Exporter service port"
    default = 9100
  
}

variable "prometheus_port" {
    description = "Prometheus port"
    default = 9091
  
}

variable "devnet_key_pair_name" {
  description = "The public key value to use for the ssh key"
  type        = string
}