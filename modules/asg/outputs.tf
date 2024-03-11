output "pk_ansible" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}
output "validator_private_ips" {
  value = aws_network_interface.validator_private.*.private_ip
}

output "fullnode_private_ips" {
  value = aws_network_interface.fullnode_private.*.private_ip
}

output "geth_private_ips" {
  value = aws_network_interface.geth_private.*.private_ip
}
