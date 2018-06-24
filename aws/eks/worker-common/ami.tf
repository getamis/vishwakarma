module "container_linux" {
  source = "../..//container_linux"

  release_channel = "${var.container_linux_channel}"
  release_version = "${var.container_linux_version}"
}

locals {
  ami_owner = "595879546273"
  arn       = "aws"
}

data "aws_ami" "coreos_ami" {
  filter {
    name   = "name"
    values = ["CoreOS-${var.container_linux_channel}-${module.container_linux.version}-*"]
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
