data "ignition_file" "kube_controller_manager" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/manifests/kube-controller-manager.yaml"

  content {
    content = templatefile("${path.module}/templates/manifests/kube-controller-manager.yaml.tpl", {
      image             = "${local.containers["kube_controller_manager"].repo}:${local.containers["kube_controller_manager"].tag}"
      kubeconfig        = "${local.etc_path}/controller-manager.conf"
      pki_path          = "${local.etc_path}/pki"
      cluster_cidr      = var.pod_network_cidr
      service_cidr      = var.service_network_cidr
      cloud_provider    = local.cloud_config.provider
      cloud_config_flag = local.cloud_config.path != "" ? "- --cloud-config=${local.cloud_config.path}" : "# no cloud provider config given"
      extra_flags       = local.controller_manager_flags
    })
  }
}

