locals {
  kubelet_config_v1beta1 = merge(local.kubelet_config, {
    apiVersion = "kubelet.config.k8s.io/v1beta1"
    kind       = "KubeletConfiguration"

    authentication = {
      x509 = {
        clientCAFile = "${local.etc_path}/pki/ca.crt"
      }
    }
    staticPodPath = "${local.etc_path}/manifests"
  })
}

data "ignition_file" "sysctl_k8s_conf" {
  path       = "/etc/sysctl.d/k8s.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = file("${path.module}/files/sysctl.d/k8s.conf")
  }
}

data "ignition_file" "get_host_info_sh" {
  path       = "${local.opt_path}/bin/get-host-info.sh"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/get-host-info.sh")
  }
}

data "ignition_file" "kubelet_wrapper_sh" {
  path       = "${local.opt_path}/bin/kubelet-wrapper"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/kubelet-wrapper.sh")
  }
}

data "ignition_file" "kubelet_csr_json_tpl" {
  count = var.control_plane ? 1 : 0

  path       = "${local.opt_path}/templates/kubelet-csr.json.tpl"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/certs/kubelet-csr.json.tpl", {
      algo = local.kubelet_cert["algo"]
      size = local.kubelet_cert["size"]
    })
  }
}

data "ignition_file" "ca_config_json_tpl" {
  count = var.control_plane ? 1 : 0

  path       = "${local.opt_path}/templates/ca-config.json.tpl"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/certs/ca-config.json.tpl", {
      expiry = local.kubelet_cert["expiry"]
    })
  }
}

data "ignition_file" "kubelet_config_tpl" {
  path       = "${local.opt_path}/templates/config.yaml.tpl"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/configs/kubelet.yaml.tpl", {
      content = local.kubelet_config_v1beta1
    })
  }
}

data "ignition_file" "kubelet_env" {
  path       = "/var/lib/kubelet/kubelet-flags.env"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/services/kubelet-flags.env.tpl", {
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
      kubeconfig           = "${local.etc_path}/kubelet.conf"
      bootstrap_kubeconfig = "${local.etc_path}/bootstrap-kubelet.conf"
    })
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubelet.service.tpl", {})
}
