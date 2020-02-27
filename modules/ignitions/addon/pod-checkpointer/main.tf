locals {
  mode = 420
}


data "template_file" "pod_checkpointer_yaml" {
  template = file("${path.module}/resources/kubernetes/addon/pod-checkpointer.yaml")

  vars = {
    pod_checkpointer_image = format("%s:%s", var.pod_checkpointer["image_path"], var.pod_checkpointer["image_tag"])
  }
}

data "ignition_file" "pod_checkpointer_yaml" {
  mode = local.mode
  path = "${pathexpand(var.addon_path)}/pod-checkpointer.yaml"

  content {
    content = data.template_file.pod_checkpointer_yaml.rendered
  }
}
