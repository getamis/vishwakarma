resource "aws_route53_zone" "zone" {
  count = var.private_zone ? 1 : 0
  name  = "${var.name}.com"

  vpc {
    vpc_id = aws_vpc.new_vpc.id
  }

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}.com",
    "Role", "dns",
  ))
}
