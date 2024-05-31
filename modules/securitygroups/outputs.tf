output "security_group_open_http_id" {
  value = aws_security_group.open_http.id
}

output "security_group_all_node_instances_id" {
  value = aws_security_group.all_node_instances.id
}

output "security_group_open_rpc_id" {
  value = aws_security_group.open_rpc.id
}

output "security_group_open_rpc_geth_id" {
  value = aws_security_group.open_rpc_geth.id
}

output "security_group_default_id" {
  value = aws_default_security_group.default.id
}
