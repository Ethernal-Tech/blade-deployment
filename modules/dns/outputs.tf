output "certificate_arn" {
  value = var.route53_zone_id == "" ? "" : aws_acm_certificate.ext_rpc[0].arn
}

output "private_zone_id" {
  value = aws_route53_zone.private_zone.id
}

output "reverse_zone_id" {
  value = aws_route53_zone.reverse_zone.id

}

output "private_zone_arn" {
  value = aws_route53_zone.private_zone.arn
}

output "reverse_zone_arn" {
  value = aws_route53_zone.reverse_zone.arn

}