

resource "aws_route53_zone" "private_zone" {
  name          = var.base_dn
  force_destroy = true
  vpc {
    vpc_id     = var.devnet_id
    vpc_region = var.region
  }
}
resource "aws_route53_zone" "reverse_zone" {
  name          = "in-addr.arpa"
  force_destroy = true
  vpc {
    vpc_id     = var.devnet_id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "int_rpc" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "int-rpc.${var.base_dn}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.aws_lb_int_rpc_domain]
}

resource "aws_route53_record" "geth_rpc" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "geth-rpc.${var.base_dn}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.aws_lb_ext_rpc_geth_domain]
}

data "aws_route53_zone" "ext_rpc" {
  count   = var.route53_zone_id == "" ? 0 : 1
  zone_id = var.route53_zone_id
}

resource "aws_acm_certificate" "ext_rpc" {
  count             = var.route53_zone_id == "" ? 0 : 1
  domain_name       = "${var.deployment_name}.${data.aws_route53_zone.ext_rpc[0].name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in(var.route53_zone_id == "" ? [] : aws_acm_certificate.ext_rpc[0].domain_validation_options) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "blade" {
  count                   = var.route53_zone_id == "" ? 0 : 1
  certificate_arn         = aws_acm_certificate.ext_rpc[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}


