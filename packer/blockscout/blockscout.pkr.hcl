packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "go_tag" {
  type    = string
  default = "1.20.11.linux-amd64"
}

variable "polycli_tag" {
  type    = string
  default = "0.1.30"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "blockscout-ami-2"
  instance_type = "t2.micro"
  region        = "us-west-2"
  ami_regions   = ["us-west-1"]
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username    = "ubuntu"
  skip_create_ami = false
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
    max_retries       = 2
    expect_disconnect = true
    execute_command   = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script            = "${path.root}/scripts/common.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/scripts/docker.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo BLADE",
      "sudo groupadd explorer-group -g 1001",
      "sudo useradd -g explorer-group -u 1001 explorer",
      "sudo usermod -a -G docker explorer",
      "sudo mkdir /etc/explorer && sudo chown -R explorer:explorer-group /etc/explorer && sudo chmod 0750 /etc/explorer",
      "sudo mkdir /opt/blockscout && sudo chown -R explorer:explorer-group /opt/blockscout && sudo chmod 0750 /opt/blockscout",
      "sudo git clone https://github.com/Ethernal-Tech/blockscout && sudo touch /opt/blockscout/blockscout.env && cd ./blockscout/docker-compose && sudo docker compose pull"

    ]


  }
}

