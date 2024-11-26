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
