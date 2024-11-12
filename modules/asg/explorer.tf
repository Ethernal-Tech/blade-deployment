resource "aws_network_interface" "explorer_private" {
  count     = var.explorer_count
  subnet_id = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
  tags = {
    Name = format("explorer-private-%03d.%s", count.index + 1, var.base_dn)
  }
}

resource "aws_instance" "explorer" {
  ami                  = var.explorer_ami
  instance_type        = var.explorer_instance_type
  count                = var.explorer_count
  key_name             = aws_key_pair.devnet.key_name
  iam_instance_profile = var.ec2_profile_name

  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  network_interface {
    network_interface_id = element(aws_network_interface.explorer_private, count.index).id
    device_index         = 0
  }

  user_data = base64encode(templatefile("${path.module}/scripts/explorer.sh", {
    deployment_name   = var.deployment_name,
    blade_home_dir    = "/opt/blockscout"
    region            = local.region
    name = format("explorer-%03d", count.index + 1)
    base_dn = var.base_dn
    volume = aws_ebs_volume.explorer[count.index].id
  }))

  tags = {
    Name              = format("explorer-%03d.%s", count.index + 1, var.base_dn)
    Hostname          = format("explorer-%03d", count.index + 1)
    Role              = "explorer"
    "service_name"    = "node_exporter"
  }
}