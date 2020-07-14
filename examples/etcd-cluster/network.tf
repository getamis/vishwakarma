locals {
  vpc_id     = data.aws_subnet.subnet.vpc_id
  etcd_sg_id = coalesce(var.etcd_security_group_id, join("", aws_security_group.etcd.*.id))
}

data "aws_subnet" "subnet" {
  id = module.network.private_subnet_ids[0]
}

data "aws_vpc" "etcd" {
  id = local.vpc_id
}

resource "aws_route53_zone" "private" {
  name = local.private_zone_name

  vpc {
    vpc_id = local.vpc_id
  }

  tags = merge(module.label.tags, map(
    "Name", local.private_zone_name,
    "Role", "etcd"
  ))
}

resource "aws_security_group" "etcd" {
  name_prefix = "${module.label.id}-etcd-"
  vpc_id      = data.aws_vpc.etcd.id

  tags = merge(module.label.tags, map(
    "Name", "${module.label.id}-etcd",
    "Role", "etcd"
  ))
}

resource "aws_security_group_rule" "etcd_egress" {
  type              = "egress"
  security_group_id = local.etcd_sg_id

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "etcd_ingress_icmp" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "etcd_ingress_etcd" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "etcd_all_self" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol  = -1
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "etcd_ssh" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.etcd.cidr_block]
  from_port   = 22
  to_port     = 22
}
