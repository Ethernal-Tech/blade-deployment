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

# resource "aws_volume_attachment" "explorer" {
#   count       = var.explorer_count
#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.explorer[count.index].id
#   instance_id = aws_instance.explorer[count.index].id
# }
