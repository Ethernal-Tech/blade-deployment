variable "network_type" {
  description = "An identifier to indicate what type of network this is"
  type        = string
}
variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}
variable "network_acl" {
  description = "Which CIDRs should be allowed to access the explorer and RPC"
  type        = list(string)
}
variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
}
variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
