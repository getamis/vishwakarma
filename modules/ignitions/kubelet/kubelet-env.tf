data "template_file" "kubelet_env" {
  template = "${file("${path.module}/resources/kubernetes/kubelet.env")}"

  vars {
    kubelet_image_url = "${var.hyperkube["image_path"]}"
    kubelet_image_tag = "${var.hyperkube["image_tag"]}"
  }
}

data "ignition_file" "kubelet_env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 0644

  content {
    content = "${data.template_file.kubelet_env.rendered}"
  }
}
