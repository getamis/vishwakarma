data "ignition_file" "kubelet_csr_json" {
  count = var.control_plane ? 1 : 0

  path       = "/opt/kubernetes/kubelet-csr.json"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/certs/kubelet-csr.json.tpl", {})
  }
}

data "ignition_file" "get_instance_info_sh" {
  path       = "/opt/kubernetes/bin/get-instance-info.sh"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/scripts/get-instance-info.sh")
  }
}

data "ignition_file" "kubelet_init_sh" {
  path       = "/opt/kubernetes/bin/kubelet-init.sh"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/scripts/kubelet-init.sh")
  }
}

data "ignition_file" "kubelet_config" {
  path       = "/var/lib/kubelet/config.yaml"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/configs/kubelet.yaml.tpl", {
      content = local.kubelet_config
    })
  }
}

data "ignition_file" "kubelet_env" {
  path       = "/var/lib/kubelet/kubelet.env"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/services/kubelet.env.tpl", {
      kubelet_image_repo             = local.container["hyperkube"].repo
      kubelet_image_tag              = local.container["hyperkube"].tag
      cfssl_image_repo               = local.container["cfssl"].repo
      cfssl_image_tag                = local.container["cfssl"].tag
      kubelet_cloud_provider         = local.cloud_config.provider
      network_plugin                 = var.network_plugin
      kubelet_cloud_provider_flag    = local.cloud_config.provider != "" ? "--cloud-provider=${local.cloud_config.provider}" : ""
      kubelet_cloud_config_path_flag = local.cloud_config.path != "" ? "--cloud-config=${local.cloud_config.path}" : ""
      extra_flags                    = local.kubelet_flags
    })
  }
}

data "ignition_file" "systemd_kubelet_conf" {
  path       = "/etc/systemd/system/kubelet.service.d/10-kubelet.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/services/10-kubelet.conf.tpl", {
      kubeconfig           = local.kubeconfig_paths["kubelet"]
      bootstrap_kubeconfig = local.kubeconfig_paths["bootstrap_kubelet"]
    })
  }
}

data "ignition_systemd_unit" "kubelet_init" {
  name    = "kubelet-init.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubelet-init.service.tpl", {})
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubelet.service.tpl", {})
}
