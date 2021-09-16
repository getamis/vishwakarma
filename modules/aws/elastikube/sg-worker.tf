resource "aws_security_group" "workers" {
  name_prefix = "${var.name}-worker-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = local.vpc_id

  tags = merge(var.extra_tags,
    {
      Name                                = "${var.name}-worker"
      Role                                = "k8s-worker"
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  type              = "egress"
  description       = "Allow nodes all egress to the Internet."
  security_group_id = aws_security_group.workers.id

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "workers_ingress_self" {
  type              = "ingress"
  description       = "Allow node to communicate with each other."
  security_group_id = aws_security_group.workers.id

  protocol  = "-1"
  from_port = 0
  to_port   = 65535
  self      = true
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  type                     = "ingress"
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = module.master.master_sg_id

  protocol  = "tcp"
  from_port = 1025
  to_port   = 65535
}

resource "aws_security_group_rule" "workers_to_coredns_tcp" {
  type                     = "ingress"
  description              = "CoreDNS TCP."
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "tcp"
  from_port = 53
  to_port   = 53
}

resource "aws_security_group_rule" "workers_to_coredns_udp" {
  type                     = "ingress"
  description              = "CoreDNS UDP."
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "udp"
  from_port = 53
  to_port   = 53
}

resource "aws_security_group_rule" "workers_to_coredns_metrics" {
  type                     = "ingress"
  description              = "CoreDNS metrics."
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "tcp"
  from_port = 9153
  to_port   = 9153
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

resource "aws_security_group_rule" "worker_ingress_flannel" {
  count             = var.network_plugin == "flannel" ? 1 : 0
  description       = "Allow access from other worker flannel."
  type              = "ingress"
  security_group_id = aws_security_group.workers.id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_flannel_from_master" {
  count                    = var.network_plugin == "flannel" ? 1 : 0
  description              = "Allow access from other master flannel."
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = module.master.master_sg_id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}
