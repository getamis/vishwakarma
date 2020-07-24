data "ignition_file" "kube_scheduler" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/manifests/kube-scheduler.yaml"

  content {
    content = templatefile("${path.module}/templates/manifests/kube-scheduler.yaml.tpl", {
      image       = "${local.containers["kube_scheduler"].repo}:${local.containers["kube_scheduler"].tag}"
      kubeconfig  = "${local.etc_path}/scheduler.conf"
      extra_flags = local.scheduler_flags
    })
  }
}
