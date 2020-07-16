locals {
  cluster_dns_ip = cidrhost(var.service_network_cidr, 10)
}

module "ignition_kubernetes" {
  source = "../../ignitions/kubernetes"

  control_plane        = false
  kubernetes_version   = var.kubernetes_version
  binaries             = var.binaries
  containers           = var.containers
  service_network_cidr = var.service_network_cidr
  network_plugin       = var.network_plugin
  tls_bootstrap_token  = var.tls_bootstrap_token

  kubelet_config = merge(var.kubelet_config, {
    clusterDNS = [local.cluster_dns_ip]
  })

  cloud_config = {
    provider = "aws"
    path     = ""
  }

  kubelet_flags = merge(var.kubelet_flags, {
    node-labels          = join(",", var.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  certs = {
    ca_cert = var.kubernetes_ca_cert
  }
}
