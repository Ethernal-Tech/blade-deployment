output "pk_ansible" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}
output "key_pair_name" {
  value = aws_key_pair.devnet.key_name
}
