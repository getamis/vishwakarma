module "ignition_tls_bootstrapping_kubeconfig" {
  source = "../../ignitions/kubeconfig"

  config_path = "/etc/kubernetes/bootstrap-kubelet.conf"

  cluster  = var.name
  context  = "kubelet-bootstrap@kubernetes"
  user     = "kubelet-bootstrap"
  endpoint = var.endpoint

  certificates = {
    ca_cert = var.kubernetes_ca_cert
    token   = "${var.tls_bootstrap_token.id}.${var.tls_bootstrap_token.secret}"
  }
}
