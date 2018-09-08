resource "aws_security_group" "eks" {
  name_prefix = "${var.phase}-${var.project}-master-"
  vpc_id      = "${var.exist_vpc_id}"

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-eks",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "eks_cluster_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.eks.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_cluster_ingress_https" {
  type              = "ingress"
  security_group_id = "${aws_security_group.eks.id}"

  protocol    = "tcp"
  cidr_blocks = ["${var.vpc_cidr_block}"]
  from_port   = 443
  to_port     = 443
}
