data "template_file" "kubelet_json" {
  template = "${file("${path.module}/resources/kubernetes/kubelet.json")}"

  vars {
    client_ca_file_path = "${var.client_ca_file_path}"
  }
}

data "ignition_file" "kubelet_json" {
  path       = "${var.kubelet_flag_config}"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${data.template_file.kubelet_json.rendered}"
  }
}