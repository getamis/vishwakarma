locals {
  architecture        = "x86_64"
  virtualization_type = "hvm"

  image_info = {
    coreos = {
      owner_id = "595879546273"
      name     = "CoreOS-stable-*"
    }

    fedora_coreos = {
      owner_id = "125523088429"
      name     = "fedora-coreos-??.????????.?.?-*"
    }

    ubuntu = {
      owner_id = "099720109477"
      name     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    }
  }
}

data "aws_ami" "os" {
  most_recent = true
  owners      = [local.image_info[var.os_name]["owner_id"]]

  filter {
    name   = "name"
    values = [local.image_info[var.os_name]["name"]]
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
