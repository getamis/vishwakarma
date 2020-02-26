locals {
  filesystem = "root"
  mode       = 420
}

data "template_file" "kube_flannel_yaml" {
  template = file("${path.module}/resources/kube-flannel.yaml")
  vars = {
    cluster_cidr  = var.cluster_cidr
    flannel_image = var.container_images["flannel"]
  }
}

data "ignition_file" "kube_flannel_yaml" {
  filesystem = local.filesystem
  mode       = local.mode
  path       = "${pathexpand(var.addon_path)}/kube-flannel.yaml"
  content {
    content = data.template_file.kube_flannel_yaml.rendered
  }
}
