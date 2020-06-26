data "aws_vpc" "master" {
  id = local.vpc_id
}

resource "aws_security_group" "master" {
  name_prefix = "${var.name}-master-"
  vpc_id      = data.aws_vpc.master.id

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}-master",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "k8s-master"
  ))

  count = var.master_security_group_id == "" ? 1 : 0
}

locals {
  master_sg_id = coalesce(var.master_security_group_id, join("", aws_security_group.master.*.id))
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = local.master_sg_id

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_ingress_icmp" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_ingress_etcd" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "master_ingress_services" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "master_all_self" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol  = -1
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "master_ingress_from_lb" {
  type                     = "ingress"
  security_group_id        = local.master_sg_id
  source_security_group_id = aws_security_group.master_lb.id

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "master_ssh" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.master.cidr_block]
  from_port   = 22
  to_port     = 22
}
