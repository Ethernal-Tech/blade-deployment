variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
}
variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
}


variable "devnet_private_subnet_ids" {
  description = "Subnet IDs used in the private network"
  type        = list(string)
}
variable "devnet_public_subnet_ids" {
  description = "Subnet IDs used in the public network"
  type        = list(string)
}

variable "devnet_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "base_id" {
  type = string
}
variable "security_group_open_http_id" {
  type = string
}
variable "security_group_default_id" {
  type = string
}

variable "certificate_arn" {
  type = string

}

variable "certificate_explorer_arn" {
  type = string
}