resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "devnet" {
  key_name   = "${var.deployment_name}_aodt_ssh_key"
  public_key = tls_private_key.pk.public_key_openssh
}


resource "aws_security_group" "aodt" {
  description = "Allow traffic from AODT ec2 for scraping metrics"

  vpc_id = var.devnet_id

  egress {
    protocol    = "TCP"
    from_port   = 9100
    to_port     = 9100
    description = "Ingress rule to allow traffic on TCP 92100 from ADOT collector"
    cidr_blocks = ["10.10.0.0/16"]

  }
  egress {
    protocol    = "TCP"
    from_port   = 9091
    to_port     = 9091
    description = "Ingress rule to allow traffic on TCP 92100 from ADOT collector"
    cidr_blocks = ["10.10.0.0/16"]

  }
  egress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    description = "Ingress rule to allow traffic on TCP 92100 from ADOT collector"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    description = "Ingress rule to allow traffic on TCP 92100 from ADOT collector"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "adot_collector" {

  ami                    = "ami-08116b9957a259459"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.aodt.id]
  iam_instance_profile   = aws_iam_instance_profile.aodt_profile.name
  subnet_id              = var.devnet_private_subnet_ids[0]
  key_name               = aws_key_pair.devnet.key_name

  user_data = base64encode(templatefile("${path.module}/scripts/adot.sh", {
    region               = "us-west-2",
    prometheus_endopoint = aws_prometheus_workspace.prometheus.prometheus_endpoint
    node_exporter_port   = var.node_exporter_port
    prometheus_port      = var.prometheus_port
  }))

  tags = {
    Name = "adot_collector"
    Role = "adot"
  }
}

resource "aws_iam_role" "aodt_role" {
  name = format("%s-%s_aodt_role", var.deployment_name, var.network_type)

  assume_role_policy = <<BLADE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
BLADE
}

resource "aws_iam_policy" "aodt_policy" {
  name        = format("%s-%s_aodt_policy", var.deployment_name, var.network_type)
  path        = "/"
  description = "Policy to provide permission to AODT"
  policy      = <<BLADE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeAvailabilityZones"
            ],
            "Resource": "*"
        }
    ]
}
BLADE
}

resource "aws_iam_role_policy_attachment" "aodt_policy_role" {
  # name       = "aodt.${var.base_dn}"
  role       = aws_iam_role.aodt_role.name
  policy_arn = aws_iam_policy.aodt_policy.arn
}


resource "aws_iam_role_policy_attachment" "ssm_aodt_role" {
  # name       = "ssm.aodt.${var.base_dn}"
  role       = aws_iam_role.aodt_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "cwa_aodt_role" {
  # name       = "cwa.aodt.${var.base_dn}"
  role       = aws_iam_role.aodt_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "prometheus_rw_aodt_role" {
  # name       = "prometheus.${var.base_dn}"
  role       = aws_iam_role.aodt_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

resource "aws_iam_instance_profile" "aodt_profile" {
  name = "aodt-profile.${var.base_dn}"
  role = aws_iam_role.aodt_role.name
}






