data "template_file" "kube_scheduler_yaml" {
  template = file("${path.module}/resources/kubernetes/manifests/kube-scheduler.yaml")

  vars = {
    hyperkube_image    = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    kubernetes_version = element(split("_", var.hyperkube["image_tag"]), 0)
  }
}

data "ignition_file" "kube_scheduler_yaml" {
  mode = local.mode
  path = "${pathexpand(var.manifest_path)}/kube-scheduler.yaml"

  content {
    content = data.template_file.kube_scheduler_yaml.rendered
  }
}
