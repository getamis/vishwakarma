resource "aws_security_group_rule" "master_ingress_flannel" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "master_ingress_flannel_from_worker" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "udp"
  cidr_blocks = ["${data.aws_vpc.master.cidr_block}"]
  from_port   = 4789
  to_port     = 4789
}

module "ignition_kube_addon_flannel_vxlan" {
  source = "../ignitions/kube-addon-flannel-vxlan"

  cluster_cidr = "${var.kube_cluster_cidr}"

  kube_apiserver_config = {
    host = "${aws_elb.master_internal.dns_name}"
    port = 443
  }
}
