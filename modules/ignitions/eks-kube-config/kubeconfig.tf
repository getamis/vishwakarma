locals {
  kubeconfig_name = "${var.kubeconfig_name == "" ? "${var.cluster_name}" : var.kubeconfig_name}"
}


data "template_file" "aws_authenticator_env_variables" {
  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  count = "${length(var.kubeconfig_aws_authenticator_env_variables)}"

  vars {
    value = "${element(values(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
    key   = "${element(keys(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
  }
}

# kubeconfig
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubernetes/kubeconfig")}"

  vars {
    kubeconfig_name                   = "${local.kubeconfig_name}"
    cluster_endpoint                  = "${var.cluster_endpoint}"
    cluster_auth_base64               = "${var.certificate_authority_data}"
    aws_authenticator_command         = "${var.kubeconfig_aws_authenticator_command}"
    aws_authenticator_command_args    = "${length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_command_args)}" : "        - ${join("\n        - ", formatlist("\"%s\"", list("token", "-i", var.cluster_name)))}"}"
    aws_authenticator_additional_args = "${length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_additional_args)}" : ""}"
    aws_authenticator_env_variables   = "${length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join("\n", data.template_file.aws_authenticator_env_variables.*.rendered)}" : ""}"
  }
}

data "ignition_file" "kubeconfig" {
  path       = "${var.kubeconfig_path}/kubeconfig"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${data.template_file.kubeconfig.rendered}"
  }
}
