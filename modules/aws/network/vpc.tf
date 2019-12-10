resource "aws_vpc" "new_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(map(
    "Name", "${var.phase}-${var.project}",
    "Phase", var.phase,
    "Project", var.project,
    "kubernetes.io/cluster/${var.phase}-${var.project}", "shared"
  ), var.extra_tags)
}

data "aws_availability_zones" "azs" {}

locals {
  aws_azs = slice(data.aws_availability_zones.azs.names, 0, var.aws_az_number)
}
