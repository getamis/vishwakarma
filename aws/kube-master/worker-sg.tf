resource "aws_security_group" "workers" {
  name_prefix = "${var.name}-worker-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${data.aws_vpc.master.id}"

  tags = "${merge(map(
      "Name", "${var.name}-worker",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description       = "Allow node to communicate with each other."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  self              = true
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.master.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_ssh" {
  description       = "Allow access from ssh."
  protocol          = "tcp"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}
