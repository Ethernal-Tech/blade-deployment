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

# resource "aws_lb_listener" "ext_rpc_secure" {
#   for_each          = var.names
#   load_balancer_arn = aws_lb.ext_rpc[each.key].arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ext_rpc.arn
#   }
# }
