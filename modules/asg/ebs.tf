resource "aws_ebs_volume" "validator" {
  count             = var.validator_count
  availability_zone = element(var.zones, count.index)
  size              = var.node_storage
  type              = "gp3"
  encrypted         = true

  tags = {
    Name     = format("validator-%03d-volume-%s", count.index + 1, var.base_dn)
    BaseDn   = var.base_dn
    Snapshot = "false"
  }
}
resource "aws_ebs_volume" "fullnode" {
  count             = var.fullnode_count
  availability_zone = element(var.zones, count.index)
  size              = var.node_storage
  type              = "gp3"
  encrypted         = true
  tags = {
    Name     = format("fullnode-%03d-volume-%s", count.index + 1, var.base_dn)
    BaseDn   = var.base_dn
    Snapshot = "false"
  }
}

resource "aws_ebs_volume" "explorer" {
  count             = var.explorer_count
  availability_zone = element(var.zones, count.index)
  size              = var.node_storage
  type              = "gp3"
  encrypted         = true
  tags = {
    Name   = format("explorer-%03d-volume-%s", count.index + 1, var.base_dn)
    BaseDn = var.base_dn
  }
}

