locals {
  architecture        = "x86_64"
  virtualization_type = "hvm"
  ami_owner           = "075585003325"
  ami_name            = "Flatcar-stable-*"
}

data "aws_ami" "os" {
  most_recent = true
  owners      = ["${local.ami_owner}"]

  filter {
    name   = "name"
    values = ["${local.ami_name}"]
  }

  filter {
    name   = "architecture"
    values = ["${local.architecture}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${local.virtualization_type}"]
  }
}