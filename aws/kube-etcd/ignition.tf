module "ignition_docker" {
  source = "../ignitions/docker"
}

module "ignition_etcd" {
  source = "../ignitions/etcd"

  name              = "${var.name}"
  discovery_service = "${local.discovery_service}"
  client_port       = "${local.client_port}"
  peer_port         = "${local.peer_port}"

  certs_config = {
    ca_cert_pem     = "${module.etcd_root_ca.cert_pem}"
    client_key_pem  = "${module.etcd_client_cert.private_key_pem}"
    client_cert_pem = "${module.etcd_client_cert.cert_pem}"
    server_key_pem  = "${module.etcd_server_cert.private_key_pem}"
    server_cert_pem = "${module.etcd_server_cert.cert_pem}"
    peer_key_pem    = "${module.etcd_peer_cert.private_key_pem}"
    peer_cert_pem   = "${module.etcd_peer_cert.cert_pem}"
  }
}

module "ignition_node_exporter" {
  source = "../ignitions/node-exporter"
}

module "ignition_locksmithd" {
  source          = "../ignitions/locksmithd"
  reboot_strategy = "${var.reboot_strategy}"
}

data "ignition_config" "main" {
  files = ["${compact(concat(
    module.ignition_docker.files,
    module.ignition_etcd.files,
    module.ignition_node_exporter.files,
    module.ignition_locksmithd.files,
    var.extra_ignition_file_ids,
  ))}"]

  systemd = ["${compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_etcd.systemd_units,
    module.ignition_node_exporter.systemd_units,
    module.ignition_locksmithd.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))}"]
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = "${var.s3_bucket}"
  key     = "ign-etcd-${var.name}.json"
  content = "${data.ignition_config.main.rendered}"
  acl     = "private"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "ign-etcd-${var.name}.json",
      "Role", "etcd",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}

data "ignition_config" "s3" {
  replace {
    source       = "${format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
