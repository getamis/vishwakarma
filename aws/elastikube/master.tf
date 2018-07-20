module "master" {
  source = "../../aws/kube-master"

  name       = "${var.name}"
  aws_region = "${var.aws_region}"

  ssh_key       = "${var.ssh_key}"
  master_config = "${var.master_config}"

  subnet_ids = ["${var.subnet_ids}"]

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

  s3_bucket = "${aws_s3_bucket.ignition.id}"

  extra_tags = "${var.extra_tags}"
}
