resource "terraform_data" "cluster" {

  depends_on = [aws_s3_object.validator_bootstrap, aws_ssm_parameter.validator_config, aws_s3_bucket.state]

  provisioner "local-exec" { # Bootstrap script called with private_ip of each node in the cluster   
    command = "${path.module}/scripts/local.sh"

    environment = {
      REGION          = var.region
      DEPLOYMENT_NAME = var.deployment_name
    }
  }
}