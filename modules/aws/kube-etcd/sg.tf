data "aws_vpc" "etcd" {
  id = local.vpc_id
}

resource "aws_security_group" "etcd" {
  name_prefix = "${var.name}-etcd-"
  vpc_id      = local.vpc_id

  tags = merge(var.extra_tags, {
    "Name" = "${var.name}-etcd"
    "Role" = "etcd"
  })
}

resource "aws_security_group_rule" "etcd_egress" {
  type              = "egress"
  security_group_id = aws_security_group.etcd.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "etcd_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol  = "tcp"
  from_port = min(local.peer_port, local.client_port)
  to_port   = max(local.peer_port, local.client_port)
  self      = true
}

resource "aws_security_group_rule" "etcd_ingress_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = var.master_security_group_id

  protocol  = "tcp"
  from_port = local.client_port
  to_port   = local.client_port
}

resource "aws_security_group_rule" "etcd_ssh" {
  count             = var.debug_mode ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "etcd_management" {
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol    = "tcp"
  cidr_blocks = var.allowed_etcd_mgmt_cidr
  from_port   = local.client_port
  to_port     = local.client_port
}

resource "aws_security_group_rule" "ingress_node_exporter_from_worker" {
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.etcd.cidr_block]
  from_port   = local.node_exporter_port
  to_port     = local.node_exporter_port
}

resource "aws_security_group_rule" "ingress_etcd_metrics_exporter_from_worker" {
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.etcd.cidr_block]
  from_port   = local.proxy_port
  to_port     = local.proxy_port
}