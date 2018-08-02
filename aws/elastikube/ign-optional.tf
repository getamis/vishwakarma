# Optional components do not affect the functionality of Kubernetes.

# ---------------------------------------------------------------------------------------------------------------------
# Prometheus Node Exporter
# ---------------------------------------------------------------------------------------------------------------------

locals {
  node_exporter_port = 9100
}

resource "aws_security_group_rule" "master_ingress_node_exporter" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "udp"
  from_port = "${local.node_exporter_port}"
  to_port   = "${local.node_exporter_port}"
  self      = true
}

resource "aws_security_group_rule" "master_ingress_node_exporter_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.workers.id}"

  protocol  = "udp"
  from_port = "${local.node_exporter_port}"
  to_port   = "${local.node_exporter_port}"
}

module "ignition_node_exporter" {
  source = "../../ignitions/node-exporter"

  listen_port = "${local.node_exporter_port}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locksmithd - Reboot strategy
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_locksmithd" {
  source          = "../../ignitions/locksmithd"
  reboot_strategy = "off"
}
