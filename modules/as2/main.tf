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
    values = ["packer-linux-aws-blade-faucet"]
  }
}

resource "aws_launch_template" "validator" {
  count         = var.validator_count
  name_prefix   = "validator-${var.base_dn}"
  instance_type = var.validator_instance_type
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
    blade_version     = var.blade_version
  }))

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [image_id]
  }

}

resource "aws_instance" "validator" {

  count     = var.validator_count
  subnet_id = element(var.private_subnet_ids, count.index)

  # wait_for_capacity_timeout = "0"
  launch_template {
    id      = aws_launch_template.validator[count.index].id
    version = aws_launch_template.validator[count.index].latest_version
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Hostname               = format("validator-%03d.%s", count.index + 1, var.base_dn)
    Name                   = format("validator-%03d.%s", count.index + 1, var.base_dn)
    Role                   = "validator"
    "asg:hostname_pattern" = format("validator-%03d.%s@%s@%s", count.index + 1, var.base_dn, var.private_zone_id, var.reverse_zone_id)
    "service_name"         = "node_exporter"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_alb_target_group_attachment" "ext" {
  count            = var.validator_count
  target_group_arn = var.ext_validator_alb_arn
  target_id        = aws_instance.validator[count.index].id
}

resource "aws_route53_record" "validator_private" {
  count   = var.validator_count
  zone_id = var.private_zone_id
  name    = format("validator-%03d.%s", count.index + 1, var.base_dn)
  type    = "A"
  ttl     = "60"
  records = [element(aws_instance.validator, count.index).private_ip]
}

resource "aws_route53_record" "validator_private_reverse" {
  count   = var.validator_count
  zone_id = var.reverse_zone_id
  records = [format("validator-%03d.%s", count.index + 1, var.base_dn)]
  type    = "PTR"
  ttl     = "60"
  name    = join(".", reverse(split(".", element(aws_instance.validator, count.index).private_ip)))
}
