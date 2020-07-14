locals {
  kubernetes_minior_version = parseint(split(".", local.container["hyperkube"].tag)[1], 10)

  root_path      = "/etc/kubernetes"
  mainifest_path = "/etc/kubernetes/manifests"
  pki_path       = "/etc/kubernetes/pki"
  etcd_pki_path  = "${local.pki_path}/etcd"
  addons_path    = "/etc/kubernetes/addons"
  config_path    = "/etc/kubernetes/config"
  log_path       = "/var/log/kubernetes"
}
