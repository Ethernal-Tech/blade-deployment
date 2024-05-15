# Blade deployment with autoscaling groups

## Packer

[Packer](https://developer.hashicorp.com/packer/tutorials/aws-get-started/get-started-install-cli) is a tool used for building Automated Machine Images (AMI).
In the packer/blade subdirectory is the .pkr.hcl file used for buildin the blade AMI. We use Packer to install all the developer tooling required to run the service like docker, cloudwatch agent, node exporter, foundry and simmilar. We alse use it to create the blade user and required directories. The AMI can be built by running the build.sh script from the packer/blade subdirectory. The output will provide us with the AMI iD

## Terraform

Terraform is used for provisioning the infrastructure. In order to provision the infrastructure, run
```bash
terraform init
terraform plan
terraform apply
```
