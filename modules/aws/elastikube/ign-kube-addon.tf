locals {
  cluster_dns_ip = cidrhost(var.service_cidr, 10)
}

# Essential components can be replaced.
# E.g., You could use your other DNS solution instead of KubeDNS.

# ---------------------------------------------------------------------------------------------------------------------
# Addon Manager
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_addon_manager" {
  source = "../../ignitions/addon/addon-manager"

  hyperkube = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = var.kubernetes_version
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CoreDNS(aka KubeDNS) addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_addon_coredns" {
  source = "../../ignitions/addon/coredns"

  reverse_cidrs  = "${var.service_cidr}"
  cluster_dns_ip = local.cluster_dns_ip
}

# ---------------------------------------------------------------------------------------------------------------------
# Kube proxy addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_addon_proxy" {
  source = "../../ignitions/addon/kube-proxy"

  cluster_cidr = var.cluster_cidr
  hyperkube = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = var.kubernetes_version
  }
}

