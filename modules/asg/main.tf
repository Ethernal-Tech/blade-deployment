resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  devnet_key_name = "${var.base_devnet_key_name}-${var.deployment_name}-${var.network_type}"
  # Use this for domains / url compatibility
  # base_dn = format("%s.%s.blade.private", var.deployment_name, var.network_type)
  # Us this for names that don't allow dots and aren't part of a url
}

resource "aws_key_pair" "devnet" {
  key_name   = local.devnet_key_name
  public_key = var.create_ssh_key ? tls_private_key.pk.public_key_openssh : var.devnet_key_value
}

resource "aws_network_interface" "validator_private" {
  count     = var.validator_count
  subnet_id = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
  security_groups = [var.sg_open_rpc_id, var.sg_all_node_id]

  tags = {
    Name = format("validator-private-%03d.%s", count.index + 1, var.base_dn)
  }
}
resource "aws_network_interface" "fullnode_private" {
  count     = var.fullnode_count
  subnet_id = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
  security_groups = [var.sg_open_rpc_id, var.sg_all_node_id]
  tags = {
    Name = format("fullnode-private-%03d.%s", count.index + 1, var.base_dn)
  }
}
resource "aws_network_interface" "geth_private" {
  count     = var.geth_count
  subnet_id = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
  security_groups = [var.sg_open_rpc_geth_id, var.sg_all_node_id]

  tags = {
    Name = format("geth-private-%03d.%s", count.index + 1, var.base_dn)
  }
}

resource "aws_launch_template" "validator" {
  count         = var.validator_count
  name_prefix   = "validator-${var.base_dn}"
  instance_type = var.base_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = var.base_ami

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    network_interface_id = element(aws_network_interface.validator_private, count.index).id
    # subnet_id = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
    device_index = 0
   
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.node_storage
      volume_type = "gp3"
    }
  }

  # vpc_security_group_ids = [var.sg_open_rpc_id, var.sg_all_node_id]

  tag_specifications {

    resource_type = "instance"

    tags = merge(
      var.default_tags, {
      Name     = format("validator-%03d.%s", count.index + 1, var.base_dn)
      Hostname = format("validator-%03d", count.index + 1)
      Role     = "validator"
    }
    )

  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

user_data = base64encode(templatefile("${path.module}/scripts/blade.sh",{
  deployment_name = var.deployment_name,
  hostname = format("validator-%03d", count.index + 1)
}))

}

resource "aws_autoscaling_group" "validator" {
  count = var.validator_count

  # availability_zones = var.zones
  availability_zones = [ element(var.zones, count.index)]

  name = "validator-${var.base_dn}-${count.index + 1}"
  # Defining the availability Zone in which AWS EC2 instance will be launched
  max_size         = 1
  desired_capacity = 1
  min_size         = 1
  # Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
  # The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type = "EC2"
  # force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete = true
  # Defining the termination policy where the oldest instance will be replaced first 
  termination_policies = ["OldestInstance"]
  # Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_template {
    id      = aws_launch_template.validator[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_validator_alb_arn]
  # vpc_zone_identifier = [for subnet in var.devnet_private_subnet_ids : subnet]
  # vpc_zone_identifier = [ element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)]

  tag {
    key                 = "Hostname"
    value               = format("validator-%03d", count.index + 1)
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = format("validator-%03d.%s", count.index + 1, var.base_dn)
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "validator"
    propagate_at_launch = true
  }

}

resource "aws_launch_template" "fullnode" {
  count         = var.fullnode_count
  name_prefix   = "fullnode-${var.base_dn}"
  instance_type = var.base_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = var.base_ami

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    network_interface_id = element(aws_network_interface.fullnode_private, count.index).id
    device_index         = 0
    # security_groups = [var.sg_open_rpc_id, var.sg_all_node_id]
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.node_storage
      volume_type = "gp3"
    }
  }

  tag_specifications {

    resource_type = "instance"

    tags = merge(
    var.default_tags,
     {
      Name     = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
      Hostname = format("fullnode-%03d", count.index + 1)
      Role     = "fullnode"
    }
    )

  }

  # vpc_security_group_ids = [var.sg_open_rpc_id, var.sg_all_node_id]

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

  user_data = base64encode(templatefile("${path.module}/scripts/blade.sh", {
    deployment_name = var.deployment_name,
    hostname = format("fullnode-%03d", count.index + 1)
  }))

}


resource "aws_autoscaling_group" "fullnode" {
  count              = var.fullnode_count
  # availability_zones = var.zones
  availability_zones = [ element(var.zones, count.index)]
  name               = "fullnode-${var.base_dn}-${count.index + 1}"
  # Defining the availability Zone in which AWS EC2 instance will be launched
  # Defining the maximum number of AWS EC2 instances while scaling
  max_size         = 1
  desired_capacity = 1
  min_size         = 1
  # Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
  # The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type = "EC2"
  # force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete = true
  # Defining the termination policy where the oldest instance will be replaced first 
  termination_policies = ["OldestInstance"]
  # Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_template {
    id      = aws_launch_template.fullnode[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_fullnode_alb_arn]
  # vpc_zone_identifier = [for subnet in var.devnet_private_subnet_ids : subnet]
  # vpc_zone_identifier = [ element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)]

  tag {
    key                 = "Hostname"
    value               = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = format("fullnode-%03d", count.index + 1)
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "fullnode"
    propagate_at_launch = true
  }

}

resource "aws_launch_template" "geth" {
  count         = var.geth_count
  name_prefix   = "geth-${var.base_dn}"
  instance_type = var.base_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = var.geth_ami

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    network_interface_id = element(aws_network_interface.geth_private, count.index).id
    device_index         = 0
    # security_groups = [var.sg_open_rpc_geth_id, var.sg_all_node_id]
  }

  tag_specifications {

    resource_type = "instance"

    tags = merge(var.default_tags,
     {
      Name     = format("geth-%03d.%s", count.index + 1, var.base_dn)
      Hostname = format("geth-%03d", count.index + 1)
      Role     = "geth"
    })

  }

  # vpc_security_group_ids = [var.sg_open_rpc_geth_id, var.sg_all_node_id]

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

}


resource "aws_autoscaling_group" "geth" {
  count              = var.geth_count
  # availability_zones = var.zones
  availability_zones = [ element(var.zones, count.index)]

  name = "geth-${var.base_dn}-${count.index + 1}"
  # Defining the availability Zone in which AWS EC2 instance will be launched
  # availability_zones = var.zones
  # Defining the maximum number of AWS EC2 instances while scaling
  max_size         = 1
  desired_capacity = 1
  min_size         = 1
  # Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
  # The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type = "EC2"
  # force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete = true
  # Defining the termination policy where the oldest instance will be replaced first 
  termination_policies = ["OldestInstance"]
  # Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_template {
    id      = aws_launch_template.geth[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_geth_alb_arn]
  # vpc_zone_identifier = [ element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)]

  tag {
    key                 = "Hostname"
    value               = format("geth-%03d", count.index + 1)
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = format("geth-%03d.%s", count.index + 1, var.base_dn)
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "geth"
    propagate_at_launch = true
  }

}
