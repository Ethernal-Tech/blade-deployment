

resource "aws_route53_zone" "private_zone" {
  name          = var.base_dn
  force_destroy = true
  vpc {
    vpc_id     = var.vpc_id
    vpc_region = var.region
  }
}
resource "aws_route53_zone" "reverse_zone" {
  name          = "in-addr.arpa"
  force_destroy = true
  vpc {
    vpc_id     = var.vpc_id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "int_rpc" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "int-rpc.${var.base_dn}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.lb_int_rpc_domain]
}

resource "aws_route53_record" "geth_rpc" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "geth-rpc.${var.base_dn}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.lb_ext_rpc_geth_domain]
}

