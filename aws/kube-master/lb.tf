resource "aws_elb" "master_internal" {
  name            = "${var.name}-master"
  subnets         = ["${var.subnet_ids}"]
  internal        = true
  security_groups = ["${aws_security_group.master_lb.id}"]

  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  tags = "${merge(map(
      "Name", "${var.name}-master",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_security_group" "master_lb" {
  vpc_id = "${data.aws_vpc.master.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  tags = "${merge(map(
      "Name", "${var.name}-master-lb-sg",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}
