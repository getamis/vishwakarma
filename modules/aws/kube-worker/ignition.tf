locals {
  cluster_dns_ip = cidrhost(var.service_network_cidr, 10)

  kubelet_node_labels = compact(concat(
    ["node.kubernetes.io/role=${var.instance_config["name"]}"],
    var.kubelet_node_labels
  ))
}

module "ignition_docker" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/docker?ref=feat/log-level"

  docker_cgroup_driver = "systemd"
  log_level            = var.log_level["docker"]
}

module "ignition_containerd" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/containerd?ref=feat/log-level"

  log_level = var.log_level["containerd"]
}

module "ignition_locksmithd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/locksmithd?ref=v1.23.10.1"

  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/update-ca-certificates?ref=v1.23.10.1"
}

module "ignition_sshd" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/sshd?ref=v1.23.10.1"

  enable = var.debug_mode
}

module "ignition_systemd_networkd" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/systemd-networkd?ref=feat/log-level"

  log_level = var.log_level["systemd_networkd"]
}

module "ignition_ecr_credentail_provider" {
  source = "github.com/getamis/terraform-ignition-reinforcements//modules/ecr-credential-provider?ref=v1.27.2.0"
}

data "aws_s3_object" "bootstrapping_kubeconfig" {
  bucket = var.s3_bucket
  key    = "bootstrap-kubelet.conf"
}

module "ignition_kubelet" {
  source = "github.com/getamis/terraform-ignition-kubernetes//modules/kubelet?ref=v1.27.4.3"

  binaries             = var.binaries
  containers           = var.containers
  kubernetes_version   = var.kubernetes_version
  service_network_cidr = var.service_network_cidr
  network_plugin       = var.network_plugin
  enable_eni_prefix    = var.enable_eni_prefix
  max_pods             = var.max_pods
  log_level            = var.log_level["kubelet"]

  extra_config = var.kubelet_config
  extra_flags = merge(var.kubelet_flags, {
    node-labels          = join(",", local.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  cloud_provider = "aws"

  bootstrap_kubeconfig_content = data.aws_s3_object.bootstrapping_kubeconfig.body
}

data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_containerd.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_sshd.files,
    module.ignition_systemd_networkd.files,
    module.ignition_kubelet.files,
    module.ignition_ecr_credentail_provider.files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_sshd.systemd_units,
    module.ignition_systemd_networkd.systemd_units,
    module.ignition_kubelet.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))
}

resource "aws_s3_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-worker-${var.instance_config["name"]}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags, {
    "Name"                              = "ign-worker-${var.instance_config["name"]}.json"
    "Role"                              = "k8s-worker"
    "kubernetes.io/cluster/${var.name}" = "owned"
  })
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
