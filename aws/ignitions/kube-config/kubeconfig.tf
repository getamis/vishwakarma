data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubernetes/kubeconfig")}"

  vars {
    cluster_name        = "${var.name}"
    api_server_endpoint = "${var.api_server_endpoint}"
    kubelet_ca          = "${base64encode(var.kube_certs["ca_cert_pem"])}"
    kubelet_cert        = "${base64encode(var.kube_certs["kubelet_cert_pem"])}"
    kubelet_key         = "${base64encode(var.kube_certs["kubelet_key_pem"])}"
  }

  count = "${var.content == "" ? 1 : 0}"
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${coalesce(var.content, join("", data.template_file.kubeconfig.*.rendered))}"
  }
}
