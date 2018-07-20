data "aws_subnet" "subnets" {
  count = "${length(var.subnet_ids)}"
  id    = "${var.subnet_ids[count.index]}"
}
