data "aws_vpc" "master" {
  id = "${local.vpc_id}"
}

resource "aws_security_group" "master" {
  name_prefix = "${var.name}-master-"
  vpc_id      = "${data.aws_vpc.master.id}"

  tags = "${merge(map(
      "Name", "${var.name}-master",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_ingress_icmp" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_ingress_etcd" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "master_ingress_services" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "master_all_from_worker" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = -1
  cidr_blocks = ["${data.aws_vpc.master.cidr_block}"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_all_self" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = -1
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "master_ingress_from_lb" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.master_lb.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group" "master_ssh" {
  name_prefix = "${var.name}-master-ssh-"
  vpc_id      = "${local.vpc_id}"

  tags = "${merge(map(
      "Name", "${var.name}-master",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "master_ssh" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master_ssh.id}"

  protocol    = "tcp"
  cidr_blocks = ["${data.aws_vpc.master.cidr_block}"]
  from_port   = 22
  to_port     = 22
}
