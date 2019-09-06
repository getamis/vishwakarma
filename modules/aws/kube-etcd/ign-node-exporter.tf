locals {
  node_exporter_port = 9100
}

resource "aws_security_group_rule" "ingress_node_exporter_from_worker" {
  type              = "ingress"
  security_group_id = aws_security_group.etcd.id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.etcd.cidr_block]
  from_port   = local.node_exporter_port
  to_port     = local.node_exporter_port
}

module "ignition_node_exporter" {
  source = "../../ignitions/node-exporter"
}
