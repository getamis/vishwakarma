data "ignition_file" "addon_manager_pod" {
  filesystem = "root"
  mode       = 420
  path       = "${var.manifests_dir_path}/addon_manager.yaml.tpl"

  content {
    content = templatefile("${path.module}/templates/pod.yaml.tpl", {
      image                         = "${var.container["repo"]}:${var.container["tag"]}"
      addons_dir_path               = var.addons_dir_path
      logs_dir_path                 = var.logs_dir_path
      kubectl_extra_prune_whitelist = join(" ", var.kubectl_extra_prune_whitelist)
    })
  }
}
