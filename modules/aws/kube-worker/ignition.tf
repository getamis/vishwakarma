locals {
  cluster_dns_ip = cidrhost(var.service_network_cidr, 10)

  kubelet_node_labels = compact(concat(
    ["node.kubernetes.io/role=${var.instance_config["name"]}"],
    var.kubelet_node_labels
  ))
}

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
  source       = "github.com/getamis/terraform-ignition-reinforcements//modules/zincati?ref=fedora_coreos"
  auto_updates = var.auto_updates
}

data "aws_s3_bucket_object" "bootstrapping_kubeconfig" {
  bucket = var.s3_bucket
  key    = "bootstrap-kubelet.conf"
}

module "ignition_kubelet" {
  source = "github.com/getamis/terraform-ignition-kubernetes//modules/kubelet?ref=fedora_coreos"

  binaries             = var.binaries
  containers           = var.containers
  kubernetes_version   = var.kubernetes_version
  service_network_cidr = var.service_network_cidr
  network_plugin       = var.network_plugin

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
    module.ignition_update_ca_trust.files,
    module.ignition_wait_for_dns.files,
    module.ignition_zincati.files,
    module.ignition_kubelet.files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_update_ca_trust.systemd_units,
    module.ignition_wait_for_dns.systemd_units,
    module.ignition_zincati.systemd_units,
    module.ignition_kubelet.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-worker-${var.instance_config["name"]}.json"
  content = data.ignition_config.main.rendered
  acl     = "private"

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags,
    {
      Name                                = "ign-worker-${var.instance_config["name"]}.json"
      Role                                = "k8s-worker"
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
