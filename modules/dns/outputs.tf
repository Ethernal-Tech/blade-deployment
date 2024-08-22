output "certificate_arn" {
  value = var.route53_zone_id == "" ? "" : aws_acm_certificate.ext_rpc[0].arn
}

output "certificate_explorer_arn" {
  value = var.route53_zone_id == "" ? "" : aws_acm_certificate.explorer[0].arn
}

output "certificate_faucet_arn" {
  value = var.route53_zone_id == "" ? "" : aws_acm_certificate.faucet[0].arn
}

output "certificate_smart_contract_verifier_arn" {
  value = var.route53_zone_id == "" ? "" : aws_acm_certificate.smart_contract_verifier[0].arn
}
