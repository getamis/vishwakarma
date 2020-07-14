resource "aws_security_group_rule" "master_ingress_flannel" {
  count             = var.network_plugin == "flannel" ? 1 : 0
  type              = "ingress"
  security_group_id = module.master.master_sg_id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "master_ingress_flannel_from_worker" {
  count                    = var.network_plugin == "flannel" ? 1 : 0
  type                     = "ingress"
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}
