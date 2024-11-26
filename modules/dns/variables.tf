variable "base_dn" {
  description = "Value of the base domain name to identify the resources"
  type        = string
}

variable "region" {
  description = "The region where we want to deploy"
  type        = string
  default     = "us-west-2"
}

variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}


variable "devnet_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "lb_int_rpc_domain" {
  type = string
}

variable "lb_ext_rpc_domain" {
  type = string

}
variable "lb_ext_rpc_geth_domain" {
  type = string
}

variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain the CNAME record to our LB"
  type        = string
}

variable "lb_explorer" {

}
