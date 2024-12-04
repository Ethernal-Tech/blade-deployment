resource "aws_network_interface" "explorer_private" {
  count     = var.explorer_count
  subnet_id = element(var.private_network_mode ? var.private_subnet_ids : var.public_subnet_ids, count.index)
  tags = {
    Name = format("explorer-private-%03d.%s", count.index + 1, var.base_dn)
  }
}

data "aws_ami" "explorer_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["blockscout-ami-2"]
  }
}

resource "aws_instance" "explorer" {
  ami                  = data.aws_ami.explorer_ami.id
  instance_type        = var.explorer_instance_type
  count                = var.explorer_count
  key_name             = var.devnet_key_name
  iam_instance_profile = var.ec2_profile_name
  subnet_id = element(var.private_network_mode ? var.private_subnet_ids : var.public_subnet_ids, count.index)

  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  vpc_security_group_ids = [var.sg_open_rpc_id, var.sg_all_node_id, var.security_group_default_id]


  user_data = base64encode(templatefile("${path.module}/scripts/explorer.sh", {
    deployment_name = var.deployment_name,
    blade_home_dir  = "/opt/blockscout"
    region          = var.region
    name            = format("explorer-%03d", count.index + 1)
    base_dn         = var.base_dn
    volume          = aws_ebs_volume.explorer[count.index].id
  }))

  tags = {
    Name           = format("explorer-%03d.%s", count.index + 1, var.base_dn)
    Hostname       = format("explorer-%03d", count.index + 1)
    Role           = "explorer"
    "service_name" = "node_exporter"
  }
}