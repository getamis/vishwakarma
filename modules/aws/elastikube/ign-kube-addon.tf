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

  hyperkube = var.hyperkube_container
}

# ---------------------------------------------------------------------------------------------------------------------
# CoreDNS(aka KubeDNS) addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_addon_coredns" {
  source = "../../ignitions/addon/coredns"

  reverse_cidrs  = "${var.service_cidr}"
  cluster_dns_ip = local.cluster_dns_ip
  replicas       = parseint(var.master_config["instance_count"], 10)
  image          = "${var.coredns_container["image_path"]}:${var.coredns_container["image_tag"]}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Kube proxy addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_addon_proxy" {
  source = "../../ignitions/addon/kube-proxy"

  cluster_cidr = var.cluster_cidr
  hyperkube    = var.hyperkube_container

}

