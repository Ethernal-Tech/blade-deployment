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
  default = "1.22.6.linux-amd64"
}

variable "polycli_tag" {
  type = string
  default = "0.1.30"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-linux-aws-geth"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-build-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
  inline = [
    "echo Installing Common Packages",
    "sleep 30",
    "sudo apt-get update",
    "sudo apt-get install -y wget apt-transport-https ca-certificates curl software-properties-common python3-pip virtualenv python3-setuptools zile gnupg net-tools inxi git make gcc jq lsof sysstat ncdu traceroute atop",
    "echo Installing cloudwatch agent",
    "wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
    "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
    "echo Installing docker",
    "for pkg in docker.io docker-doc docker-compose docker-compose-v2 containerd runc; do sudo apt-get remove $pkg; done",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    "echo Installig golang",
    "sudo wget https://go.dev/dl/go${var.go_tag}.tar.gz -O /opt/go${var.go_tag}.tar.gz",
    "sudo chmod 0755 /opt/go${ var.go_tag }.tar.gz",
    "file /opt/go${ var.go_tag }.tar.gz",
    "sudo tar -C /usr/local/ -xzf /opt/go${ var.go_tag }.tar.gz ",
    "sudo ln -s /usr/local/go/bin/go /usr/local/bin/go",
    "echo Installing polycli",
    "sudo wget https://github.com/maticnetwork/polygon-cli/releases/download/v${ var.polycli_tag }/polycli_${ var.polycli_tag }_linux_amd64.tar.gz -O /opt/polycli_${ var.polycli_tag }_linux_amd64.tar.gz",
    "sudo tar -C /usr/local/ -xzf /opt/polycli_${ var.polycli_tag }_linux_amd64.tar.gz",
    "sudo ln -s /usr/local/polycli_${ var.polycli_tag }_linux_amd64/polycli /usr/local/bin/polycli",
    "echo Installing foundry",
    "curl -L https://foundry.paradigm.xyz | bash",
    "sleep 5",
    "/home/ubuntu/.foundry/bin/foundryup",
    "sudo cp /home/ubuntu/.foundry/bin/* /usr/local/bin",
    "echo GETH",
    "sudo groupadd geth-group",
    "sudo useradd -g geth-group geth",
    "sudo mkdir /etc/geth && sudo chown -R geth:geth-group /etc/geth && sudo chmod 0750 /etc/geth"


  ]
}

}
