locals {
  ubuntu_owner_id        = "099720109477"
  coreos_owner_id        = "595879546273"
  fedora_coreos_owner_id = "125523088429"

  architecture        = "x86_64"
  virtualization_type = "hvm"
}

data "aws_ami" "ubuntu_bionic" {
  most_recent = true
  owners      = [local.ubuntu_owner_id]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = [local.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = [local.virtualization_type]
  }
}


data "aws_ami" "coreos" {
  most_recent = true
  owners      = [local.coreos_owner_id]

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "architecture"
    values = [local.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = [local.virtualization_type]
  }
}

data "aws_ami" "fedora_coreos" {
  most_recent = true
  owners      = [local.fedora_coreos_owner_id]

  filter {
    name   = "name"
    values = ["fedora-coreos-??.????????.?.?-*"]
  }

  filter {
    name   = "architecture"
    values = [local.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = [local.virtualization_type]
  }
}
