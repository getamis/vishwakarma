data "ignition_file" "kube_controller_manager" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.mainifest_path}/kube-controller-manager.yaml"

  content {
    content = templatefile("${path.module}/templates/manifests/kube-controller-manager.yaml.tpl", {
      image             = "${local.containers["kube_controller_manager"].repo}:${local.containers["kube_controller_manager"].tag}"
      kubeconfig        = local.kubeconfig_paths["controller_manager"]
      pki_path          = local.pki_path
      cluster_cidr      = var.pod_network_cidr
      service_cidr      = var.service_network_cidr
      cloud_provider    = local.cloud_config.provider
      cloud_config_flag = local.cloud_config.path != "" ? "- --cloud-config=${local.cloud_config.path}" : "# no cloud provider config given"
      extra_flags       = local.controller_manager_flags
    })
  }
}

