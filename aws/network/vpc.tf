data "aws_availability_zones" "azs" {}

resource "aws_vpc" "new_vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-vpc",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}
