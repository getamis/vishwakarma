locals {
  cluster_dns_ip = cidrhost(var.service_network_cidr, 10)

  kubelet_node_labels = compact(concat(
    list("node.kubernetes.io/role=${var.instance_config["name"]}"),
    var.kubelet_node_labels
  ))
}

module "ignition_docker" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/docker?ref=v1.1.5"
}

module "ignition_locksmithd" {
  source          = "github.com/getamis/terraform-ignition-reinforcements//modules/locksmithd?ref=v1.1.5"
  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/update-ca-certificates?ref=v1.1.5"
}

module "ignition_sshd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/sshd?ref=v1.1.5"

  enable = var.debug_mode
}

module "ignition_systemd_networkd" {
  source   = "github.com/getamis/terraform-ignition-reinforcements//modules/systemd-networkd?ref=v1.1.5"

  debug = var.debug_mode
}

module "ignition_legacy_cgroups" {
  source   = "github.com/getamis/terraform-ignition-reinforcements//modules/legacy-cgroups?ref=v1.1.5"
}

data "aws_s3_bucket_object" "bootstrapping_kubeconfig" {
  bucket = var.s3_bucket
  key    = "bootstrap-kubelet.conf"
}

module "ignition_kubelet" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-kubernetes?ref=feature/node-graceful-shutdown"

  binaries             = var.binaries
  containers           = var.containers
  kubernetes_version   = var.kubernetes_version
  service_network_cidr = var.service_network_cidr
  network_plugin       = var.network_plugin
  enable_eni_prefix    = var.enable_eni_prefix
  max_pods             = var.max_pods

  extra_config = var.kubelet_config
  extra_flags = merge(var.kubelet_flags, {
    node-labels          = join(",", local.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  cloud_config = {
    provider = "aws"
    path     = ""
  }

  bootstrap_kubeconfig_content = data.aws_s3_bucket_object.bootstrapping_kubeconfig.body
}

data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_sshd.files,
    module.ignition_systemd_networkd.files,
    module.ignition_legacy_cgroups.files,
    module.ignition_kubelet.files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_sshd.systemd_units,
    module.ignition_systemd_networkd.systemd_units,
    module.ignition_legacy_cgroups.systemd_units,
    module.ignition_kubelet.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))

  filesystems = compact(concat(
    module.ignition_legacy_cgroups.filesystems,
  ))
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-worker-${var.instance_config["name"]}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags, map(
    "Name", "ign-worker-${var.instance_config["name"]}.json",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "k8s-worker"
  ))
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
