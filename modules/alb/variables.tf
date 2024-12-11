variable "names" {
  type = set(string)

}
variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
}
variable "public_subnet_ids" {
  description = "Subnet IDs used in the public network"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "base_id" {
  description = "TODO"
  type        = string
}
variable "security_group_open_http_id" {
  description = "TODO"
  type        = string
}
variable "security_group_default_id" {
  description = "TODO"
  type        = string
}
