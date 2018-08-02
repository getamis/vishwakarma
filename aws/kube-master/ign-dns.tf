module "ignition_kube_addon_dns" {
  source = "../../ignitions/kube-addon-dns"

  cluster_dns_ip = "${local.cluster_dns_ip}"
}
