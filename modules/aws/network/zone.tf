resource "aws_route53_zone" "zone" {
  count = var.private_zone ? 1 : 0
  name  = "${var.phase}-${var.project}.com"

  vpc_id = aws_vpc.new_vpc.id

  tags = merge(map(
      "Name", "${var.phase}-${var.project}.com",
      "Phase", var.phase,
      "Project", var.project,
      "kubernetes.io/cluster/${var.phase}-${var.project}", "shared"
    ), var.extra_tags)
}
