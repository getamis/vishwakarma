resource "aws_security_group_rule" "master_ingress_flannel" {
  type              = "ingress"
  security_group_id = module.master.master_sg_id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "master_ingress_flannel_from_worker" {
  type                     = "ingress"
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}

module "ignition_network_flannel" {
  source = "../../ignitions/network-plugin/flannel"

  cluster_cidr = var.cluster_cidr
}
