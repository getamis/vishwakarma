data "aws_subnet" "subnet" {
  id = var.private_subnet_ids[0]
}

locals {
  vpc_id            = data.aws_subnet.subnet.vpc_id
  private_zone_name = coalesce(var.hostzone, format("%s.com", var.name))
}

resource "aws_route53_zone" "private" {
  name = local.private_zone_name

  vpc {
    vpc_id = local.vpc_id
  }

  tags = merge(var.extra_tags, map(
    "Name", local.private_zone_name,
    "kubernetes.io/cluster/${var.name}", "shared"
  ))
}
