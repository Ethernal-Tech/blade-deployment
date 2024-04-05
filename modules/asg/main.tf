resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  devnet_key_name = "${var.base_devnet_key_name}-${var.deployment_name}-${var.network_type}"
}

resource "aws_key_pair" "devnet" {
  key_name   = local.devnet_key_name
  public_key = var.create_ssh_key ? tls_private_key.pk.public_key_openssh : var.devnet_key_value
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
    subnet_id       = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
    security_groups = [var.sg_open_rpc_id, var.sg_all_node_id, var.security_group_default_id]

  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.node_storage
      volume_type = "gp3"
      encrypted   = true
    }
  }


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

  user_data = base64encode(templatefile("${path.module}/scripts/blade.sh", {
    deployment_name = var.deployment_name,
    hostname        = format("validator-%03d", count.index + 1)
  }))

  lifecycle {
    create_before_destroy = false
  }


}

resource "aws_autoscaling_group" "validator" {
  count = var.validator_count

  availability_zones = [element(var.zones, count.index)]

  name = aws_launch_template.validator[count.index].id

  max_size                  = 1
  desired_capacity          = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.validator[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_validator_alb_arn, var.ext_validator_alb_arn]
  initial_lifecycle_hook {
    name                    = "${aws_launch_template.validator[count.index].id}-lifecycle-launching"
    default_result          = "ABANDON"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = aws_sns_topic.autoscale_handling.arn
    role_arn                = aws_iam_role.lifecycle.arn
  }

  # initial_lifecycle_hook {
  #   name                    = "${aws_launch_template.validator[count.index].id}-lifecycle-terminating"
  #   default_result          = "ABANDON"
  #   heartbeat_timeout       = 60
  #   lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  #   notification_target_arn = aws_sns_topic.autoscale_handling.arn
  #   role_arn                = aws_iam_role.lifecycle.arn
  # }
  warm_pool {

  }
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

  tag {
    key = "asg:hostname_pattern"
    # Ensure that the value you choose here contains a fully qualified domain name for the zone before the @ symbol
    value               = format("validator-%03d.%s@%s@%s", count.index + 1, var.base_dn, var.private_zone_id, var.reverse_zone_id)
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
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
    subnet_id       = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
    security_groups = [var.sg_open_rpc_id, var.sg_all_node_id,var.security_group_default_id]
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

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

  user_data = base64encode(templatefile("${path.module}/scripts/blade.sh", {
    deployment_name = var.deployment_name,
    hostname        = format("fullnode-%03d", count.index + 1)
  }))

  lifecycle {
    create_before_destroy = false
  }


}

resource "aws_autoscaling_group" "fullnode" {
  count = var.fullnode_count

  availability_zones = [element(var.zones, count.index)]
  name               = aws_launch_template.fullnode[count.index].id
  max_size           = 1
  desired_capacity   = 1
  min_size           = 1

  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.fullnode[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_fullnode_alb_arn]
  # initial_lifecycle_hook {
  #   name                    = "${aws_launch_template.fullnode[count.index].id}-lifecycle-launching"
  #   default_result          = "ABANDON"
  #   heartbeat_timeout       = 60
  #   lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  #   notification_target_arn = aws_sns_topic.autoscale_handling.arn
  #   role_arn                = aws_iam_role.lifecycle.arn
  # }

  # initial_lifecycle_hook {
  #   name                    = "${aws_launch_template.fullnode[count.index].id}-lifecycle-terminating"
  #   default_result          = "ABANDON"
  #   heartbeat_timeout       = 60
  #   lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  #   notification_target_arn = aws_sns_topic.autoscale_handling.arn
  #   role_arn                = aws_iam_role.lifecycle.arn
  # }
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

  tag {
    key = "asg:hostname_pattern"
    # Ensure that the value you choose here contains a fully qualified domain name for the zone before the @ symbol
    value               = format("fullnode-%03d.%s@%s@%s", count.index + 1, var.base_dn, var.private_zone_id, var.reverse_zone_id)
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
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
    subnet_id       = element(var.private_network_mode ? var.devnet_private_subnet_ids : var.devnet_public_subnet_ids, count.index)
    security_groups = [var.sg_open_rpc_geth_id, var.sg_all_node_id, var.security_group_default_id]
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
  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

  lifecycle {
    create_before_destroy = false
  }


}


resource "aws_autoscaling_group" "geth" {
  count              = var.geth_count
  availability_zones = [element(var.zones, count.index)]

  name_prefix = aws_launch_template.geth[count.index].id

  max_size                  = 1
  desired_capacity          = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.geth[count.index].id
    version = "$Latest"
  }
  target_group_arns = [var.int_geth_alb_arn]
  # initial_lifecycle_hook {
  #   name                    = "${aws_launch_template.geth[count.index].id}-lifecycle-launching"
  #   default_result          = "ABANDON"
  #   heartbeat_timeout       = 60
  #   lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  #   notification_target_arn = aws_sns_topic.autoscale_handling.arn
  #   role_arn                = aws_iam_role.lifecycle.arn
  # }

  # initial_lifecycle_hook {
  #   name                    = "${aws_launch_template.geth[count.index].id}-lifecycle-terminating"
  #   default_result          = "ABANDON"
  #   heartbeat_timeout       = 60
  #   lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  #   notification_target_arn = aws_sns_topic.autoscale_handling.arn
  #   role_arn                = aws_iam_role.lifecycle.arn
  # }
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

  tag {
    key = "asg:hostname_pattern"
    # Ensure that the value you choose here contains a fully qualified domain name for the zone before the @ symbol
    value               = format("geth-%03d.%s@%s@%s", count.index + 1, var.base_dn, var.private_zone_id, var.reverse_zone_id)
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
  }


}
