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

resource "aws_security_group_rule" "master_ingress" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.master.cidr_block]
  from_port   = var.apiserver_secure_port
  to_port     = var.apiserver_secure_port
}

resource "aws_security_group_rule" "master_ingress_from_lb" {
  type                     = "ingress"
  security_group_id        = local.master_sg_id
  source_security_group_id = aws_security_group.master_lb.id

  protocol  = "tcp"
  from_port = var.apiserver_secure_port
  to_port   = var.apiserver_secure_port
}

resource "aws_security_group_rule" "master_ssh" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.master.cidr_block]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "master_ingress_kubelet_secure_from_worker" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.master.cidr_block]
  from_port   = 10255
  to_port     = 10255
}

# resource "aws_security_group_rule" "master_ingress_coredns_tcp_from_worker" {
#   type              = "ingress"
#   security_group_id = local.master_sg_id

#   protocol    = "tcp"
#   cidr_blocks = [data.aws_vpc.master.cidr_block]
#   from_port   = 53
#   to_port     = 53
# }

# resource "aws_security_group_rule" "master_ingress_coredns_udp_from_worker" {
#   type              = "ingress"
#   security_group_id = local.master_sg_id

#   protocol    = "udp"
#   cidr_blocks = [data.aws_vpc.master.cidr_block]
#   from_port   = 53
#   to_port     = 53
# }

# resource "aws_security_group_rule" "master_ingress_coredns_metrics_from_worker" {
#   type              = "ingress"
#   security_group_id = local.master_sg_id

#   protocol    = "tcp"
#   cidr_blocks = [data.aws_vpc.master.cidr_block]
#   from_port   = 9153
#   to_port     = 9153
# }

resource "aws_security_group_rule" "master_ingress_flannel" {
  count             = var.network_plugin == "flannel" ? 1 : 0
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}
