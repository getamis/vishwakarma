data "template_file" "provision" {
  template = "${file("${path.module}/resources/services/provision.service")}"

  vars {
    api_server_secret_path = "${local.api_server_secret_path}"
    api_server_secret_key_path = "${local.api_server_secret_path}/apiserver.key"
    api_server_secret_crt_path = "${local.api_server_secret_path}/apiserver.crt"

    state_path = "${var.state_path}"
    state_key_path = "${var.state_path}/key.pem"
    state_crt_path = "${var.state_path}/cert.pem"
  }
}

data "ignition_systemd_unit" "provision" {
  name    = "authenticator-provision.service"
  enabled = true
  content = "${data.template_file.provision.rendered}"
}

locals {
  api_server_secret_path = "/etc/kubernetes/secrets"
}
