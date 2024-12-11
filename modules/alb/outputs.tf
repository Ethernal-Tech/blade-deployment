output "lb_arns" {
  value = {
    for k in var.names : k => aws_lb_target_group.ext_rpc[k].arn
  }

}
