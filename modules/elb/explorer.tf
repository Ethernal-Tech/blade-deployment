resource "aws_lb" "explorer" {
  name               = "explorer-${var.base_id}"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.devnet_public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]
}

resource "aws_lb_target_group" "explorer" {
  name        = "explorer-${var.base_id}"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  port        = 4000
}
resource "aws_lb_listener" "explorer" {
  load_balancer_arn = aws_lb.explorer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer.arn
  }
}

resource "aws_lb_listener" "explorer_secure" {
  load_balancer_arn = aws_lb.explorer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_explorer_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer.arn
  }
}