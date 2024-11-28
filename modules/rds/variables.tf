variable "base_id" {
  description = "Value of the base id name to identify the resources"
  type        = string
}

variable "explorer_rds_master_password" {
  description = "The master password used to configure the rds cluster"
  type        = string
  sensitive   = true
}

variable "explorer_count" {
  description = "The number of nodes to run as a blockchain explorer"
  type        = number
}

variable "zones" {
  description = "The availability zones for deployment"
  type        = list(string)
}

variable "devnet_private_subnet_ids" {
  description = "The cidr block for the private subnet in our VPC"
  type = list(string)
}