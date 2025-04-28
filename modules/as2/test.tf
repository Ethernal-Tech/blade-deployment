resource "aws_launch_template" "test" {
  count         = var.enable_test_nodes ? 1 : 0
  name_prefix   = "test_fullnode"
  instance_type = var.fullnode_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = data.aws_ami.base_ami.id

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    subnet_id       = element(var.private_subnet_ids, count.index)
    security_groups = [var.sg_open_rpc_id, var.sg_all_node_id, var.security_group_default_id]
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = var.node_storage
      encrypted   = true
      volume_type = "gp3"
    }
  }

  tag_specifications {

    resource_type = "instance"

    tags = merge(
      var.default_tags,
      {
        Name     = format("fullnode-test.%s", var.base_dn)
        Hostname = format("fullnode-test")
        Role     = "testnode"
      }
    )

  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "ip-name"
  }

  user_data = base64encode(templatefile("${path.module}/scripts/test.sh", {
    deployment_name   = var.deployment_name,
    hostname          = format("fullnode-test.%s", var.base_dn)
    name              = format("fullnode-test")
    is_bootstrap_node = false
    blade_home_dir    = var.blade_home_dir
    base_dn           = var.base_dn
    region            = var.region
    blade_version     = var.blade_version
  }))

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [image_id]
  }

}

resource "aws_instance" "test" {
  count             = var.enable_test_nodes ? 1 : 0
  availability_zone = element(var.zones, count.index)

  launch_template {
    id      = aws_launch_template.test[count.index].id
    version = aws_launch_template.test[count.index].latest_version
  }


  tags = {
    Hostname = format("fullnode-test-same.%s", var.base_dn)
    Name     = format("fullnode-test-same.%s", var.base_dn)
    Role     = "testnode"
  }

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_autoscaling_group" "test" {
  count            = var.enable_test_nodes ? 1 : 0
  max_size         = 1
  min_size         = 0
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.test[count.index].id
    version = "$Latest"
  }


  tag {
    key                 = "BaseDN"
    propagate_at_launch = true
    value               = var.base_dn
  }

}
