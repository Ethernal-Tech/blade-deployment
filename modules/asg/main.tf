resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_cloudwatch_log_group" "blade" {
  name = "docker-logs-${var.deployment_name}"
}
resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.create_ssh_key ? tls_private_key.pk.public_key_openssh : var.devnet_key_value
}
data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["packer-linux-aws-blade"]
  }
}

resource "aws_launch_template" "validator" {
  count         = var.validator_count
  name_prefix   = "validator-${var.base_dn}"
  instance_type = var.base_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = data.aws_ami.base_ami.id

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  vpc_security_group_ids = [var.sg_open_rpc_id, var.sg_all_node_id, var.security_group_default_id]

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tag_specifications {

    resource_type = "instance"

    tags = merge(
      var.default_tags,
      {
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
    deployment_name   = var.deployment_name
    blade_home_dir    = var.blade_home_dir
    base_dn           = var.base_dn
    region            = var.region
    is_bootstrap_node = false
    hostname          = format("validator-%03d.%s", count.index + 1, var.base_dn)
    name              = format("validator-%03d", count.index + 1)
    volume            = element(aws_ebs_volume.validator, count.index).id
  }))

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_autoscaling_group" "validator" {

  count               = var.validator_count
  vpc_zone_identifier = [element(var.private_subnet_ids, count.index)]
  name                = "${var.deployment_name}-validator-asg-${count.index}"

  max_size                  = 1
  desired_capacity          = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]

  # wait_for_capacity_timeout = "0"
  launch_template {
    id      = aws_launch_template.validator[count.index].id
    version = aws_launch_template.validator[count.index].latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }

  }
  target_group_arns = [var.int_validator_alb_arn, var.ext_validator_alb_arn]

  initial_lifecycle_hook {
    name                    = "${aws_launch_template.validator[count.index].id}-lifecycle-launching"
    default_result          = "ABANDON"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = var.sns_topic_arn
    role_arn                = var.lifecycle_role
  }

  tag {
    key                 = "Hostname"
    value               = format("validator-%03d.%s", count.index + 1, var.base_dn)
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

  tag {
    key                 = "service_name"
    value               = "node_exporter"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
  }
}
