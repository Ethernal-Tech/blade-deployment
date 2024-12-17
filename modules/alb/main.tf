resource "aws_lb" "ext_rpc" {
  for_each           = var.names
  name               = "${each.key}-${var.base_id}"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]
}
resource "aws_lb_target_group" "ext_rpc" {
  for_each    = var.names
  name        = "${each.key}-${var.base_id}"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  port        = var.http_rpc_port
}

resource "aws_lb_listener" "ext_rpc" {
  for_each          = var.names
  load_balancer_arn = aws_lb.ext_rpc[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_rpc[each.key].arn
  }
}

resource "aws_lb_listener" "ext_rpc_secure" {
  for_each          = var.names
  load_balancer_arn = aws_lb.ext_rpc[each.key].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert[each.key].arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_rpc[each.key].arn
  }
}

resource "tls_private_key" "ext_rpc" {
  for_each  = var.names
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ext_rpc" {
  for_each        = var.names
  private_key_pem = tls_private_key.ext_rpc[each.key].private_key_pem

  subject {
    common_name  = aws_lb.ext_rpc[each.value].dns_name
    organization = "Ethernal"
  }

  validity_period_hours = 300

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
resource "aws_acm_certificate" "cert" {
  for_each         = var.names
  private_key      = tls_private_key.ext_rpc[each.key].private_key_pem
  certificate_body = tls_self_signed_cert.ext_rpc[each.key].cert_pem
}
