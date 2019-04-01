locals {
  ami_owner = "595879546273"
  arn       = "aws"

  container_linux_channel = "stable"
  container_linux_version = "latest"
}

module "container_linux" {
  source = "../container_linux"

  release_channel = "${local.container_linux_channel}"
  release_version = "${local.container_linux_version}"
}

data "aws_ami" "coreos_ami" {

  owners = ["${local.ami_owner}"]

  filter {
    name   = "name"
    values = ["CoreOS-${local.container_linux_channel}-${module.container_linux.version}-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["${local.ami_owner}"]
  }
}
