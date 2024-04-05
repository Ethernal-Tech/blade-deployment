packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "debug_mode" {
  type    = bool
  default = false
}

variable "remove_ami" {
  description = "Remove the previous AMI with same name"
  type        = bool
  default     = true
}

variable "go_tag" {
  type    = string
  default = "1.21.6.linux-amd64"
}

variable "polycli_tag" {
  type    = string
  default = "0.1.30"
}

variable "node_major" {
  type    = string
  default = "20"
}

source "amazon-ebs" "ubuntu" {
  skip_create_ami       = var.debug_mode
  force_deregister      = var.remove_ami
  force_delete_snapshot = var.remove_ami
  ami_name              = "load-test-${formatdate("YYYY-MM-DD", timestamp())}"
  ami_description       = "Load testing on blockchain verifies the system's ability to handle a large number of transactions, ensuring performance and scalability."
  instance_type         = "t2.micro"
  region                = "us-west-2"
  availability_zone     = "us-west-2a"
  source_ami            = "ami-0efcece6bed30fd98"
  ssh_username          = "ubuntu"
  run_tags = {
    OS   = "ubuntu"
    Name = "load-test-${formatdate("YYYY-MM-DD", timestamp())}"
    Libs = "jq, make, foundry, forge, cast, go, polycli, k6, xk6, xk6-ethereum, nodejs, npm, yarn, pandoras-box"
    Rule = "loadtestrunner"
  }
}

build {
  name = "load-test"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars  = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command   = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    max_retries       = 2 # sometimes fails to update/upgrade Ubuntu
    expect_disconnect = true
    script            = "${path.root}/scripts/common.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/foundry.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "GO_TAG=${var.go_tag}"
    ]
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/scripts/golang.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "POLYCLI_TAG=${var.polycli_tag}"
    ]
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/scripts/polycli.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/k6.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/xk6.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/xk6-ethereum.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "NODE_MAJOR=${var.node_major}"
    ]
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "${path.root}/scripts/nodejs.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/yarn.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/pandoras-box.sh"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "${path.root}/scripts/verify.sh"
  }
}