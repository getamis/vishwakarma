data "aws_subnet" "exist" {
  id = "${var.exist_subnet_ids[0]}"
}

data "aws_vpc" "exist" {
  id = "${data.aws_subnet.exist.vpc_id}"
}

resource "aws_security_group" "eks" {
  name_prefix = "${var.phase}-${var.project}-eks-"
  vpc_id      = "${data.aws_vpc.exist.id}"

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-eks",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "eks_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.eks.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_ingress_https_from_vpc" {
  type              = "ingress"
  security_group_id = "${aws_security_group.eks.id}"

  protocol    = "tcp"
  cidr_blocks = "${var.cidr_access_eks_endpoint}"
  from_port   = 443
  to_port     = 443
}
