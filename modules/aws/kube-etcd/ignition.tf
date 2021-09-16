module "ignition_docker" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/docker?ref=fedora_coreos"
}

module "ignition_update_ca_trust" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/update-ca-trust?ref=fedora_coreos"
}

module "ignition_wait_for_dns" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/wait-for-dns?ref=fedora_coreos"
}

module "ignition_zincati" {
  source          = "github.com/getamis/terraform-ignition-reinforcements//modules/zincati?ref=fedora_coreos"
  auto_updates = var.auto_updates
}

module "ignition_node_exporter" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/node-exporter?ref=fedora_coreos"
}

module "ignition_etcd" {
  source = "github.com/getamis/terraform-ignition-etcd?ref=fedora_coreos"

  name                  = var.name
  binaries              = var.binaries
  discovery_service_srv = local.discovery_service
  client_port           = local.client_port
  peer_port             = local.peer_port
  device_name           = var.instance_config["data_device_rename"]
  data_path             = var.instance_config["data_path"]

  certs = {
    ca_cert     = module.etcd_ca.cert_pem
    client_key  = module.etcd_client_cert.private_key_pem
    client_cert = module.etcd_client_cert.cert_pem
    server_key  = module.etcd_server_cert.private_key_pem
    server_cert = module.etcd_server_cert.cert_pem
    peer_key    = module.etcd_peer_cert.private_key_pem
    peer_cert   = module.etcd_peer_cert.cert_pem
  }
}

data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_update_ca_trust.files,
    module.ignition_wait_for_dns.files,
    module.ignition_zincati.files,
    module.ignition_etcd.files,
    module.ignition_node_exporter.files,
    var.extra_ignition_file_ids
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_update_ca_trust.systemd_units,
    module.ignition_wait_for_dns.systemd_units,
    module.ignition_zincati.systemd_units,
    module.ignition_etcd.systemd_units,
    module.ignition_node_exporter.systemd_units,
    var.extra_ignition_systemd_unit_ids
  ))

  filesystems = module.ignition_etcd.filesystems
  disks       = module.ignition_etcd.disks
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-etcd-${var.name}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags,
    {
      Name                                = "ign-etcd-${var.name}.json"
      Role                                = "etcd"
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
