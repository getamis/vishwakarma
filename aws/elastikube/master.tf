module "master" {
  source = "../../aws/kube-master"

  name       = "${var.name}"
  aws_region = "${var.aws_region}"

  ssh_key       = "${var.ssh_key}"
  master_config = "${var.master_config}"
  role_name     = "${var.master_role_name}"

  security_group_ids    = [
    "${aws_security_group.master2etcd.id}",
    "${var.security_group_ids}"
  ]
  lb_security_group_ids = ["${var.lb_security_group_ids}"]
  subnet_ids            = ["${var.subnet_ids}"]

  etcd_endpoints = ["${module.etcd.endpoints}"]

  etcd_certs_config = {
    ca_cert_pem     = "${module.etcd.ca_cert_pem}"
    client_key_pem  = "${module.etcd.client_key_pem}"
    client_cert_pem = "${module.etcd.client_cert_pem}"
  }

  kube_service_cidr = "${var.service_cidr}"
  kube_cluster_cidr = "${var.cluster_cidr}"

  kube_node_labels = [
    "${compact(concat(
        list("node-role.kubernetes.io/master"),
        var.extra_master_node_labels,
      ))}",
  ]

  kube_node_taints = [
    "${compact(concat(
        list("node-role.kubernetes.io/master=:NoSchedule"),
        var.extra_master_node_taints,
      ))}",
  ]

  s3_bucket                       = "${aws_s3_bucket.ignition.id}"
  reboot_strategy                 = "${var.reboot_strategy}"
  extra_ignition_file_ids         = ["${var.extra_ignition_file_ids}"]
  extra_ignition_systemd_unit_ids = ["${var.extra_ignition_systemd_unit_ids}"]

  extra_tags = "${var.extra_tags}"
}

resource "aws_security_group" "master2etcd" {
  name_prefix = "${var.name}-master2etcd-"
  vpc_id      = "${local.vpc_id}"

  tags = "${merge(map(
      "Name", "${var.name}-master2etcd",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}
