output "aws_lb_int_rpc_domain" {
  value = aws_lb.int_rpc.dns_name
}
output "aws_lb_p2p_domain" {
  value = aws_lb.ext_p2p.dns_name
}
output "aws_lb_ext_rpc_domain" {
  value = aws_lb.ext_rpc.dns_name
}
output "aws_lb_ext_rpc_geth_domain" {
  value = aws_lb.ext_rpc_geth.dns_name
}
output "aws_lb_explorer_domain" {
  value = var.explorer_count == 1 ? aws_lb.explorer[0].dns_name : ""
}
