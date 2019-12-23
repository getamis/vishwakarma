data "template_file" "kube_proxy_yaml" {
  template = file("${path.module}/resources/kubernetes/addon/kube-proxy.yaml")

  vars = {
    hyperkube_image = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    cluster_cidr    = var.cluster_cidr
  }
}

data "ignition_file" "kube_proxy_yaml" {
  filesystem = "root"
  mode       = 420
  path       = "${pathexpand(var.addon_path)}/kube-proxy.yaml"

  content {
    content = data.template_file.kube_proxy_yaml.rendered
  }
}
