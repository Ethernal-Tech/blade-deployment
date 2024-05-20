resource "aws_lb" "int_rpc" {
  name               = "int-rpc-${var.base_id}"
  load_balancer_type = "network"
  internal           = true
  subnets            = var.devnet_private_subnet_ids
}
resource "aws_lb_target_group" "int_rpc" {
  name        = "int-rpc-${var.base_id}"
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = var.http_rpc_port
}

resource "aws_lb_target_group_attachment" "int_rpc" {
  count            = var.fullnode_count
  target_group_arn = aws_lb_target_group.int_rpc.arn
  target_id        = element(var.fullnode_instance_ids, count.index)
  port             = var.http_rpc_port
}

resource "aws_lb_listener" "int_rpc" {
  load_balancer_arn = aws_lb.int_rpc.arn
  port              = var.http_rpc_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_rpc.arn
  }
}

resource "aws_lb" "ext_rpc" {
  name               = "ext-rpc-${var.base_id}"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.devnet_public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]
}
resource "aws_lb_target_group" "ext_rpc" {
  name        = "ext-rpc-${var.base_id}"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = var.http_rpc_port
}

resource "aws_lb_target_group" "ext_jsonrpc_node" {
  count       = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  name        = format("ext-jsonrpc-%s-%03d", var.base_id, count.index + 1)
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = var.http_rpc_port
}
resource "aws_lb_target_group_attachment" "ext_jsonrpc_node" {
  count            = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  target_group_arn = aws_lb_target_group.ext_jsonrpc_node[count.index].arn
  target_id        = element(var.fullnode_count > 0 ? var.fullnode_instance_ids : var.validator_instance_ids, count.index)
  port             = var.http_rpc_port
}
resource "aws_lb_listener" "ext_jsonrpc_node" {
  count             = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  load_balancer_arn = aws_lb.ext_rpc.arn
  port              = 8000 + count.index + 1
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_jsonrpc_node[count.index].arn
  }
}

resource "aws_lb_target_group_attachment" "ext_rpc" {
  count            = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  target_group_arn = aws_lb_target_group.ext_rpc.arn
  target_id        = element(var.fullnode_count > 0 ? var.fullnode_instance_ids : var.validator_instance_ids, count.index)
  port             = var.http_rpc_port
}
resource "aws_lb_listener" "ext_rpc" {
  load_balancer_arn = aws_lb.ext_rpc.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_rpc.arn
  }
}

# resource "aws_lb_listener" "ext_rpc_secure" {
#   count             = var.route53_zone_id == "" ? 0 : 1
#   load_balancer_arn = aws_lb.ext_rpc.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ext_rpc.arn
#   }
# }

resource "aws_lb" "ext_rpc_geth" {
  name               = "ext-rpc-rootchain-${var.base_id}"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.devnet_public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]
}
resource "aws_lb_target_group" "ext_rpc_geth" {
  name        = "ext-rpc-rootchain-${var.base_id}"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = var.rootchain_rpc_port
}
resource "aws_lb_target_group_attachment" "ext_rpc_geth" {
  count            = var.geth_count
  target_group_arn = aws_lb_target_group.ext_rpc_geth.arn
  target_id        = element(var.geth_instance_ids, count.index)
  port             = var.rootchain_rpc_port
}
resource "aws_lb_listener" "ext_rpc_geth" {
  load_balancer_arn = aws_lb.ext_rpc_geth.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_rpc_geth.arn
  }
}

resource "aws_lb" "ext_p2p" {
  name               = "ext-p2p-${var.base_id}"
  load_balancer_type = "network"
  internal           = false
  subnets            = var.devnet_public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]
}

resource "aws_lb_target_group" "ext_grpc_node" {
  count       = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  name        = format("ext-grpc-%s-%03d", var.base_id, count.index + 1)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = 10000
}
resource "aws_lb_target_group_attachment" "ext_grpc_node" {
  count            = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  target_group_arn = aws_lb_target_group.ext_grpc_node[count.index].arn
  target_id        = element(var.fullnode_count > 0 ? var.fullnode_instance_ids : var.validator_instance_ids, count.index)
  port             = 10000
}
resource "aws_lb_listener" "ext_grpc_node" {
  count             = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  load_balancer_arn = aws_lb.ext_p2p.arn
  port              = 7000 + count.index + 1
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_grpc_node[count.index].arn
  }
}

resource "aws_lb_target_group" "ext_p2p_node" {
  count       = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  name        = format("ext-p2p-%s-%03d", var.base_id, count.index + 1)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = 10001
}
resource "aws_lb_target_group_attachment" "ext_p2p_node" {
  count            = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  target_group_arn = aws_lb_target_group.ext_p2p_node[count.index].arn
  target_id        = element(var.fullnode_count > 0 ? var.fullnode_instance_ids : var.validator_instance_ids, count.index)
  port             = 10001
}
resource "aws_lb_listener" "ext_p2p_node" {
  count             = var.fullnode_count > 0 ? var.fullnode_count : var.validator_count
  load_balancer_arn = aws_lb.ext_p2p.arn
  port              = 9000 + count.index + 1
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_p2p_node[count.index].arn
  }
}

resource "aws_lb" "explorer" {
  count              = var.explorer_count
  name               = "explorer-${var.base_id}"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.devnet_public_subnet_ids
  security_groups    = [var.security_group_open_http_id, var.security_group_default_id]

}
resource "aws_lb_target_group" "explorer" {
  count       = var.explorer_count
  name        = "explorer-${var.base_id}"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.devnet_id
  port        = 3000
}
resource "aws_lb_target_group_attachment" "explorer" {
  count            = length(var.explorer_instance_ids)
  target_group_arn = aws_lb_target_group.explorer[count.index].arn
  target_id        = element(var.explorer_instance_ids, count.index)
  port             = 3000
}
resource "aws_lb_listener" "explorer" {
  count             = var.explorer_count
  load_balancer_arn = aws_lb.explorer[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer[0].arn
  }
}
