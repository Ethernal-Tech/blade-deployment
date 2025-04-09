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
  ami_name      = "packer-linux-aws-blade-faucet"
  instance_type = "t2.micro"
  region        = "us-west-2"
  ami_regions   = ["us-west-1", "eu-central-1"]
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
  skip_create_ami = false
}

build {
  name = "packer-build-ubuntu"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source = "conf/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }

   provisioner "file" {
    source = "scripts/run.sh"
    destination = "/tmp/run.sh"
  }

  provisioner "file" {
    source = "conf/cw_agent_config.json"
    destination = "/tmp/cw_agent_config.json"
  }

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
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "GOLANG_VERSION=${var.go_tag}"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/golang.sh"
  }
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/foundry.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/cloudwatch.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/node_exporter.sh"
}
    provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "POLYCLI_TAG=${var.polycli_tag}"
    ]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/polycli.sh"
  }

  provisioner "shell" {
  environment_vars= ["DEBIAN_FRONTEND=noninteractive"]
  inline = [
    "echo BLADE",
    "sudo groupadd blade-group -g 1001",
    "sudo useradd -g blade-group -u 1001 blade",
    "sudo usermod -a -G docker blade",
    "sudo mkdir /etc/blade && sudo chown -R blade:blade-group /etc/blade && sudo chmod 0750 /etc/blade"
  ]
}

provisioner "shell" {
environment_vars = [
  "DEBIAN_FRONTEND=noninteractive",
  "POLYCLI_TAG=${var.polycli_tag}"
]
execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
script           = "${path.root}/scripts/faucet.sh"
}


}
