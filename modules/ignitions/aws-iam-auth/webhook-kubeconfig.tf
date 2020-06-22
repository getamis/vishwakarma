data "template_file" "kubeconfig" {
  template = file("${path.module}/resources/kubernetes/webhook/kubeconfig")

  vars = {
    webhook_ca          = var.webhook_kubeconfig_ca
    webhook_server_port = var.server_port
  }
}

data "ignition_file" "kubeconfig" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${pathexpand(var.webhook_kubeconfig_path)}/kubeconfig"

  content {
    content = data.template_file.kubeconfig.rendered
  }
}
