resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(var.extra_tags, {
    "Name" = "${var.name}-igw"
    "Role" = "network"
  })
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(var.extra_tags, {
    "Name" = "${var.name}-public"
    "Role" = "network"
  })
}

resource "aws_main_route_table_association" "main_vpc_routes" {
  vpc_id         = aws_vpc.new_vpc.id
  route_table_id = aws_route_table.default.id
}

resource "aws_route" "igw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.default.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "public_subnet" {
  count             = length(local.aws_azs)
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.new_vpc.cidr_block, 4, count.index)
  availability_zone = local.aws_azs[count.index]

  tags = merge(var.extra_tags, {
    "Name" = "${var.name}-public-${local.aws_azs[count.index]}"
    "Role" = "network"
  })
}

resource "aws_route_table_association" "route_net" {
  count          = length(local.aws_azs)
  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
}

resource "aws_eip" "nat_eip" {
  count  = length(local.aws_azs)
  domain = "vpc"

  # Terraform does not declare an explicit dependency towards the internet gateway.
  # this can cause the internet gateway to be deleted/detached before the EIPs.
  # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(local.aws_azs)
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]
}
