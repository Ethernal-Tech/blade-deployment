locals {
  load_balancers    = transpose(var.load_balancers)
  target_group_arns = flatten([[var.int_fullnode_alb_arn], var.load_balancers])
}

resource "aws_launch_template" "fullnode" {
  count         = var.fullnode_count
  name_prefix   = "fullnode-${var.base_dn}"
  instance_type = var.fullnode_instance_type
  key_name      = aws_key_pair.devnet.key_name
  image_id      = data.aws_ami.base_ami.id

  iam_instance_profile {
    name = var.ec2_profile_name
  }

  network_interfaces {
    subnet_id       = element(var.private_network_mode ? var.private_subnet_ids : var.public_subnet_ids, count.index)
    security_groups = [var.sg_open_rpc_id, var.sg_all_node_id, var.security_group_default_id]
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
    deployment_name   = var.deployment_name,
    hostname          = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
    name              = format("fullnode-%03d", count.index + 1)
    is_bootstrap_node = false
    blade_home_dir    = var.blade_home_dir
    base_dn           = var.base_dn
    region            = var.region
    volume            = element(aws_ebs_volume.fullnode, count.index).id
    blade_version     = var.blade_version
  }))

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [image_id]
  }

}

resource "aws_instance" "fullnode" {
  count = var.fullnode_count

  availability_zone = element(var.zones, count.index)


  launch_template {
    id      = aws_launch_template.fullnode[count.index].id
    version = aws_launch_template.fullnode[count.index].latest_version
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Hostname               = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
    Name                   = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
    Role                   = "fullnode"
    "asg:hostname_pattern" = format("fullnode-%03d.%s@%s@%s", count.index + 1, var.base_dn, var.private_zone_id, var.reverse_zone_id)
  }

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_alb_target_group_attachment" "fullnode" {
  count            = var.fullnode_count
  target_group_arn = var.int_fullnode_alb_arn
  target_id        = aws_instance.fullnode[count.index].id

}

resource "aws_route53_record" "fullnode_private" {
  count   = var.fullnode_count
  zone_id = var.private_zone_id
  name    = format("fullnode-%03d.%s", count.index + 1, var.base_dn)
  type    = "A"
  ttl     = "60"
  records = [element(aws_instance.fullnode, count.index).private_ip]
}

resource "aws_route53_record" "fullnode_private_reverse" {
  count   = var.fullnode_count
  zone_id = var.reverse_zone_id
  records = [format("fullnode-%03d.%s", count.index + 1, var.base_dn)]
  type    = "PTR"
  ttl     = "60"
  name    = join(".", reverse(split(".", element(aws_instance.fullnode, count.index).private_ip)))
}
