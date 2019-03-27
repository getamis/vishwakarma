resource "aws_elb" "master_internal" {
  name     = "${var.name}-master"
  subnets  = ["${split(",", var.endpoint_public_access == true ? join(",", var.public_subnet_ids) : join(",", var.private_subnet_ids))}"]
  internal = "${var.endpoint_public_access == true ? false : true }"

  security_groups = [
    "${aws_security_group.master_lb.id}",
    "${var.lb_security_group_ids}",
  ]

  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "SSL:443"
    interval            = 5
  }

  tags = "${merge(map(
      "Name", "${var.name}-master",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group" "master_lb" {
  name_prefix = "${var.name}-master-lb-"
  vpc_id      = "${data.aws_vpc.master.id}"

  tags = "${merge(map(
      "Name", "${var.name}-master-lb",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "master_lb_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.master_lb.id}"

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_lb_ingress_from_internal" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master_lb.id}"

  protocol    = "tcp"
  cidr_blocks = ["${ var.endpoint_public_access == true ? "0.0.0.0/0" : data.aws_vpc.master.cidr_block}"]
  from_port   = 443
  to_port     = 443
}
