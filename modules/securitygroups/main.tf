# Default Security Group of VPC should allow all traffic that's internal
resource "aws_default_security_group" "default" {
  vpc_id = var.devnet_id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
}

resource "aws_security_group" "all_node_instances" {
  name        = format("all-%s-%s-nodes", var.network_type, var.deployment_name)
  description = format("Configuration for the %s %s collection of instances", var.network_type, var.deployment_name)
  vpc_id      = var.devnet_id
}
resource "aws_security_group_rule" "all_node_instances" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.all_node_instances.id
}


resource "aws_security_group" "open_rpc" {
  name        = "internal-rpc-access"
  description = "Allowing internal rpc"
  vpc_id      = var.devnet_id
}
resource "aws_security_group_rule" "open_rpc" {
  type              = "ingress"
  from_port         = var.http_rpc_port
  to_port           = var.http_rpc_port
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_rpc.id
}

resource "aws_security_group_rule" "open_node_exporter" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_rpc.id
}

resource "aws_security_group_rule" "open_prometheys" {
  type              = "ingress"
  from_port         = 9091
  to_port           = 9091
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_rpc.id
}

resource "aws_security_group" "open_http" {
  name        = "external-explorer-access"
  description = "Allowing explorer acccess"
  vpc_id      = var.devnet_id
}
resource "aws_security_group_rule" "open_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_http.id
}
resource "aws_security_group_rule" "open_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_http.id
}

resource "aws_security_group" "open_rpc_geth" {
  name        = "internal-geth-access"
  description = "configuration for geth access"
  vpc_id      = var.devnet_id
}
resource "aws_security_group_rule" "open_rpc_geth" {
  type              = "ingress"
  from_port         = var.rootchain_rpc_port
  to_port           = var.rootchain_rpc_port
  protocol          = "TCP"
  cidr_blocks       = var.network_acl
  security_group_id = aws_security_group.open_rpc_geth.id
}
