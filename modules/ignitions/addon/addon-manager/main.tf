data "template_file" "kube_addon_manager" {
  template = file("${path.module}/resources/services/kube-addon-manager.service")

  vars = {
    hyperkube_image = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    addon_path      = var.addon_path
  }
}

data "ignition_systemd_unit" "kube_addon_manager" {
  name    = "kube-addon-manager.service"
  enabled = true
  content = data.template_file.kube_addon_manager.rendered
}
