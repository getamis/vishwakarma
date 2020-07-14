data "ignition_file" "kubeconfig" {
  filesystem = "root"
  mode       = 420
  path       = "${pathexpand(var.kubeconfig_dir_path)}/kubeconfig"

  content {
    content = templatefile("${path.module}/templates/kubeconfig.tpl", {
      ca          = base64encode(var.auth_ca_cert)
      server_port = var.server_port
    })
  }
}

data "ignition_file" "iam_auth_cert" {
  filesystem = "root"
  mode       = 420
  path       = "${var.state_path}/cert.pem"

  content {
    content = var.auth_cert
  }
}

data "ignition_file" "iam_auth_key" {
  filesystem = "root"
  mode       = 420
  path       = "${var.state_path}/key.pem"

  content {
    content = var.auth_cert_key
  }
}

