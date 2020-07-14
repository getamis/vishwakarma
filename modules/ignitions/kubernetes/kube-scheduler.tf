data "ignition_file" "kube_scheduler" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.mainifest_path}/kube-scheduler.yaml"

  content {
    content = templatefile("${path.module}/templates/manifests/kube-scheduler.yaml.tpl", {
      image       = "${local.container["hyperkube"].repo}:${local.container["hyperkube"].tag}"
      kubeconfig  = local.kubeconfig_paths["scheduler"]
      extra_flags = local.scheduler_flags
    })
  }
}
