data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = var.config_path
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/kubeconfig.yaml.tpl", {
      cluster                = var.cluster
      endpoint               = var.endpoint
      context                = var.context
      user                   = var.user
      token                  = local.certificates["token"]
      cluster_ca_certificate = base64encode(local.certificates["ca_cert"])
      client_cert_data       = base64encode(local.certificates["client_cert"])
      client_key_data        = base64encode(local.certificates["client_key"])
      client_cert_path       = local.certificates["client_cert_path"]
      client_key_path        = local.certificates["client_key_path"]
      content                = var.content
    })
  }
}