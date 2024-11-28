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

variable "security_group_default_id" {
  description = "Default security group id"
  type        = string

}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string

}

variable "node_exporter_port" {
  type        = number
  description = "Node Exporter service port"
  default     = 9100

}

variable "prometheus_port" {
  type        = number
  description = "Prometheus port"
  default     = 9091

}
