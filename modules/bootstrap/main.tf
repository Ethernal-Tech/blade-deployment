resource "random_pet" "server" {
  prefix = var.deployment_name
}


resource "terraform_data" "cluster" {

  depends_on = [aws_s3_object.validator_bootstrap, aws_ssm_parameter.validator_config, aws_s3_bucket.state]

  provisioner "local-exec" { # Bootstrap script called with private_ip of each node in the cluster
    command = "${path.module}/scripts/local.sh > output_local.txt 2>&1"

    environment = {
      REGION                = var.region
      DEPLOYMENT_NAME       = var.deployment_name
      RANDOM_PET            = random_pet.server.id
      AWS_ACCESS_KEY_ID     = var.access_key_id
      AWS_SECRET_ACCESS_KEY = var.secret_access_key
    }
  }
}
