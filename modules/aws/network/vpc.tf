resource "aws_vpc" "new_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}",
    "Role", "network"
  ))
}

data "aws_availability_zones" "azs" {}

locals {
  aws_azs = slice(data.aws_availability_zones.azs.names, 0, var.aws_az_number)
}
