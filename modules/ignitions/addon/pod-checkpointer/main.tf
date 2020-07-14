data "ignition_file" "pod_checkpointer" {
  filesystem = "root"
  mode       = 420
  path       = "${pathexpand(var.addons_path)}/pod-checkpointer.yaml"

  content {
    content = templatefile("${path.module}/templates/pod-checkpointer.yaml.tpl", {
      image = "${var.container.repo}:${var.container.tag}"
    })
  }
}
