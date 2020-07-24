locals {
  architecture        = "x86_64"
  virtualization_type = "hvm"

  image_info = {
    coreos = {
      owner_id = "595879546273"
      name     = "CoreOS-${var.channel}-*"
    }

    flatcar = {
      owner_id = "075585003325"
      name     = "Flatcar-${var.channel}-*"
    }

    fedora_coreos = {
      owner_id = "125523088429"
      name     = "fedora-coreos-??.????????.${var.channel_version}"
    }

    ubuntu = {
      owner_id = "099720109477"
      name     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    }
  }
}

data "aws_ami" "os" {
  most_recent = true
  owners      = [local.image_info[var.flavor]["owner_id"]]

  filter {
    name   = "name"
    values = [local.image_info[var.flavor]["name"]]
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
