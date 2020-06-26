data "template_file" "kubeconfig" {
  template = file("${path.module}/resources/kubeconfig")

  vars = {
    webhook_ca          = base64encode(var.aws_iam_auth_ca)
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
