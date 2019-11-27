locals {
  cluster_dns_ip = cidrhost(var.service_cidr, 10)
}

# Essential components can be replaced.
# E.g., You could use your other DNS solution instead of KubeDNS.

# ---------------------------------------------------------------------------------------------------------------------
# Addon Manager
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_kube_addon_manager" {
  source = "../../ignitions/kube-addon-manager"

  hyperkube = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = var.kubernetes_version
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# KubeDNS addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_kube_addon_dns" {
  source = "../../ignitions/kube-addon-dns"

  reverse_cidrs  = "${var.service_cidr}"
  cluster_dns_ip = local.cluster_dns_ip
}

# ---------------------------------------------------------------------------------------------------------------------
# Kube proxy addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_kube_addon_proxy" {
  source = "../../ignitions/kube-addon-proxy"

  cluster_cidr = var.cluster_cidr

  hyperkube = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = var.kubernetes_version
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Flannel addon
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "master_ingress_flannel" {
  type              = "ingress"
  security_group_id = module.master.master_sg_id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "master_ingress_flannel_from_worker" {
  type                     = "ingress"
  security_group_id        = module.master.master_sg_id
  source_security_group_id = aws_security_group.workers.id

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}

module "ignition_kube_addon_flannel_vxlan" {
  source = "../../ignitions/kube-addon-flannel-vxlan"

  cluster_cidr = var.cluster_cidr
}
