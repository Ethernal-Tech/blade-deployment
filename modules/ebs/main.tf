resource "aws_ebs_volume" "validator" {
  count             = var.validator_count
  availability_zone = element(var.zones, count.index)
  size              = var.node_storage
  type              = "gp3"

  tags = {
    Name = format("validator-%03d-volume", count.index + 1)
    Snapshot = "true"
  }
}

resource "aws_ebs_volume" "fullnode" {
  count             = var.fullnode_count
  availability_zone = element(var.zones, count.index)
  size              = var.node_storage
  type              = "gp3"
  tags = {
    Name = format("fullnode-%03d-volume", count.index + 1)
    Snapshot = "true"
  }
}
