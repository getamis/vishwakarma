data "template_file" "kube_dns_yaml" {
  template = "${file("${path.module}/resources/kubernetes/manifests/kube-dns.yaml")}"

  vars {
    kubedns_image         = "${var.images["kubedns"]}"
    kubednsmasq_image     = "${var.images["kubednsmasq"]}"
    kubedns_sidecar_image = "${var.images["kubedns_sidecar"]}"
    kubedns_service_ip    = "${var.cluster_dns_ip}"
  }
}

data "ignition_file" "kube_dns_yaml" {
  filesystem = "${local.filesystem}"
  mode       = "${local.mode}"

  path = "${pathexpand(var.addon_path)}/kube-dns.yaml"

  content {
    content = "${data.template_file.kube_dns_yaml.rendered}"
  }
}
