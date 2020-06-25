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

# ---------------------------------------------------------------------------------------------------------------------
# Kube auth addon
# ---------------------------------------------------------------------------------------------------------------------

module "kube_auth" {
  source = "../kube-auth"

  name                   = var.name
  ignition_s3_bucket     = aws_s3_bucket.ignition.id
  oidc_s3_bucket         = "${var.name}-${md5("${aws_route53_zone.private.zone_id}-oidc")}"
  oidc_issuer_pubkey     = module.master.service_account_pubkey
  webhook_kubeconfig_ca  = module.master.certificate_authority
  extra_tags = var.extra_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Kube audit addon
# ---------------------------------------------------------------------------------------------------------------------

module "ignition_kube_audit" {
  source = "../../ignitions/kube-audit"

  audit_policy_path = var.audit_policy_path
  audit_policy      = var.audit_policy
}