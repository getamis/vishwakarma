data "template_file" "aws_auth_cm" {
  template = "${file("${path.module}/resources/aws-auth-cm.yaml.tpl")}"
}

resource "local_file" "aws_auth_cm" {
  content  = "${data.template_file.aws_auth_cm.rendered}"
  filename = "${var.config_output_path}/aws-auth-cm.yaml"
}

resource "null_resource" "aws_auth_cm" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}/aws-auth-cm.yaml --kubeconfig ${var.config_output_path}/kubeconfig"
  }

  triggers {
    kubeconfig_rendered = "${data.template_file.kubeconfig.rendered}"
  }
}
