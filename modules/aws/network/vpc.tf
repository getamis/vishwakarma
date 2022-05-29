resource "aws_vpc" "new_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.extra_tags, {
    "Name" = var.name
    "Role" = "network"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  aws_azs = slice(data.aws_availability_zones.available.names, 0, 2)

}
