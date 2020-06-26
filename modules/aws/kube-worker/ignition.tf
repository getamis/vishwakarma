locals {
  cluster_dns_ip = cidrhost(var.kube_service_cidr, 10)
}

module "ignition_docker" {
  source = "../../ignitions/docker"
}

module "ignition_locksmithd" {
  source          = "../../ignitions/locksmithd"
  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "../../ignitions/update-ca-certificates"
}

data "aws_s3_bucket_object" "kubeconfig" {
  bucket = var.s3_bucket
  key    = "kubeconfig"
}

module "ignition_kube_config" {
  source  = "../../ignitions/kube-config"
  content = data.aws_s3_bucket_object.kubeconfig.body
}

module "ignition_kubelet" {
  source = "../../ignitions/kubelet"

  kubelet_flag_cloud_provider = "aws"
  kubelet_flag_cluster_dns    = local.cluster_dns_ip

  kubelet_flag_node_labels = join(",", compact(concat(
    list("node-role.kubernetes.io/${var.worker_config["name"]}"),
    var.kube_node_labels,
  )))

  kubelet_flag_register_with_taints = join(",", var.kube_node_taints)
  kubelet_flag_extra_flags          = var.kubelet_flag_extra_flags

  hyperkube = var.hyperkube_container

  network_plugin = var.network_plugin
}

data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_kubelet.files,
    module.ignition_kube_config.files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_kubelet.systemd_units,
    module.ignition_kube_config.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-worker-${var.worker_config["name"]}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags, map(
    "Name", "ign-worker-${var.worker_config["name"]}.json",    
    "kubernetes.io/cluster/${var.cluster_name}", "owned",
    "Role", "k8s-worker"
  ))
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
