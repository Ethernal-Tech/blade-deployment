packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "go_tag" {
  type = string
  default = "1.20.11.linux-amd64"
}

variable "polycli_tag" {
  type = string
  default = "0.1.30"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-linux-aws-hyperledger"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  skip_create_ami = true
}

build {
  name = "packer-build-ubuntu"
  
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

    provisioner "shell" {
        environment_vars = [
        "DEBIAN_FRONTEND=noninteractive"
        ]
        max_retries = 2
        expect_disconnect = true
        execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
        script           = "${path.root}/scripts/common.sh"
    }

   provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/docker.sh"
  }
 
 provisioner "shell" {
  environment_vars= ["DEBIAN_FRONTEND=noninteractive"]
  inline = [
    "echo BLADE",
    "sudo groupadd blade-group -g 1001",
    "sudo useradd -g blade-group -u 1001 blade",
    "sudo usermod -a -G docker blade",
    "sudo usermod -a -G docker ubuntu"
  ]
}

 provisioner "shell" {
  environment_vars= ["DEBIAN_FRONTEND=noninteractive"]
  inline = [
    "sudo systemctl enable docker",
    "sudo systemctl start docker",
    "curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && sudo chmod +x install-fabric.sh && ./install-fabric.sh"
  ]
}

  



}
