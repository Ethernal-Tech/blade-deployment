# resource "aws_ebs_volume" "validator" {
#   count             = var.validator_count
#   availability_zone = element(var.zones, count.index)
#   size              = var.node_storage
#   type              = "gp3"
#   tags = {
#     Name = format("validator-%03d", count.index + 1)
#   }
# }