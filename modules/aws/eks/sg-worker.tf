resource "aws_security_group" "worker" {
  name_prefix = "${var.phase}-${var.project}-worker-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${data.aws_subnet.exist.vpc_id}"

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-worker",
      "kubernetes.io/cluster/${var.phase}-${var.project}", "owned",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "worker_egress" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.worker.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "worker_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.worker.id}"
  self                     = true
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_from_eks" {
  description              = "Allow workers kubelet and pod to be accessed from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.eks.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_from_ssh" {
  description              = "Allow access from ssh."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker.id}"
  cidr_blocks              = "${var.cidr_access_worker_ssh}"
  from_port                = 22
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_lb" {

  count = "${length(var.lb_sg_ids)}"

  type                     = "ingress"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${var.lb_sg_ids[count.index]}"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
}
