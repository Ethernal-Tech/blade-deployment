data "aws_vpc_endpoint_service" "ec2" {
  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2.service_name
  vpc_endpoint_type = "Interface"
}