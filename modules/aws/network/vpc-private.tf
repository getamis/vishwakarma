resource "aws_route_table" "private_routes" {
  count  = length(local.aws_azs)
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(map(
    "Name", "${var.phase}-${var.project}-private-${local.aws_azs[count.index]}",
    "Phase", var.phase,
    "Project", var.project,
    "kubernetes.io/cluster/${var.phase}-${var.project}", "shared"
  ), var.extra_tags)
}

resource "aws_route" "to_nat_gw" {
  count                  = length(local.aws_azs)
  route_table_id         = aws_route_table.private_routes.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
  depends_on             = [aws_route_table.private_routes]
}

resource "aws_subnet" "private_subnet" {
  count             = length(local.aws_azs)
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.new_vpc.cidr_block, 4, count.index + length(local.aws_azs))
  availability_zone = local.aws_azs[count.index]

  tags = merge(map(
    "Name", "${var.phase}-${var.project}-private-${local.aws_azs[count.index]}",
    "Phase", var.phase,
    "Project", var.project,
    "kubernetes.io/cluster/${var.phase}-${var.project}", "shared"
  ), var.extra_tags)
}

resource "aws_route_table_association" "private_routing" {
  count          = length(local.aws_azs)
  route_table_id = aws_route_table.private_routes.*.id[count.index]
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
}
