resource "aws_security_group" "master" {
  name_prefix = "${var.name}-master-"
  vpc_id      = "${local.vpc_id}"

  tags = "${merge(map(
      "Name", "${var.name}-master",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}
