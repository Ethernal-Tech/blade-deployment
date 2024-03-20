output "aws_lb_int_rpc_domain" {
  value = aws_lb.int_rpc.dns_name
}

output "aws_lb_ext_rpc_domain" {
  value = aws_lb.ext_rpc.dns_name
}
output "aws_lb_ext_rpc_geth_domain" {
  value = aws_lb.ext_rpc_geth.dns_name
}

output "tg_int_rpc_domain" {
  value = aws_lb_target_group.int_rpc.arn
}

output "tg_ext_rpc_domain" {
  value = aws_lb_target_group.ext_rpc.arn
}
output "tg_ext_rpc_geth_domain" {
  value = aws_lb_target_group.ext_rpc_geth.arn
}