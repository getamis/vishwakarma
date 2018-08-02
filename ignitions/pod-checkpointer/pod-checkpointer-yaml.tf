data "template_file" "pod_checkpointer_yaml" {
  template = "${file("${path.module}/resources/kubernetes/manifests/pod-checkpointer.yaml")}"

  vars {
    pod_checkpointer_image = "${var.pod_checkpointer["image_path"]}:${var.pod_checkpointer["image_tag"]}"
  }
}

data "ignition_file" "pod_checkpointer_yaml" {
  filesystem = "${local.filesystem}"
  mode       = "${local.mode}"

  path = "${pathexpand(var.manifest_path)}/pod-checkpointer.yaml"

  content {
    content = "${data.template_file.pod_checkpointer_yaml.rendered}"
  }
}
