module "ignition_docker" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/docker?ref=v1.31.1.2"

  docker_cgroup_driver = "systemd"
  log_level            = var.log_level["docker"]
}

module "ignition_containerd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/containerd?ref=v1.31.1.2"

  log_level = var.log_level["containerd"]
}

module "ignition_locksmithd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/locksmithd?ref=v1.31.1.2"

  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/update-ca-certificates?ref=v1.31.1.2"
}

module "ignition_node_exporter" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/node-exporter?ref=v1.31.1.2"
}

module "ignition_sshd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/sshd?ref=v1.31.1.2"

  enable = var.debug_mode
}

module "ignition_amazon_ec2_net_utils" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/amazon-ec2-net-utils?ref=v1.31.1.2"

  enabled = var.apply_amazon_ec2_net_utils
}

module "ignition_etcd" {
  source = "github.com/getamis/terraform-ignition-etcd?ref=v1.31.1.0"

  name                  = var.name
  containers            = var.containers
  discovery_service_srv = local.discovery_service
  client_port           = local.client_port
  peer_port             = local.peer_port
  proxy_port            = local.proxy_port
  device_name           = var.instance_config["data_device_rename"]
  data_path             = var.instance_config["data_path"]
  log_level             = var.log_level["etcd"]

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
    module.ignition_containerd.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_etcd.files,
    module.ignition_node_exporter.files,
    module.ignition_sshd.files,
    module.ignition_amazon_ec2_net_utils.files,
    var.extra_ignition_file_ids
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_etcd.systemd_units,
    module.ignition_node_exporter.systemd_units,
    module.ignition_sshd.systemd_units,
    module.ignition_amazon_ec2_net_utils.systemd_units,
    var.extra_ignition_systemd_unit_ids
  ))

  filesystems = module.ignition_etcd.filesystems
  disks       = module.ignition_etcd.disks
}

resource "aws_s3_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-etcd-${var.name}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = {
    "Name"                              = "ign-etcd-${var.name}.json"
    "Role"                              = "etcd"
    "kubernetes.io/cluster/${var.name}" = "owned"
  }
}


data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
