locals {
  etc_path = "/etc/kubernetes"
  opt_path = "/opt/kubernetes"
  log_path = "/var/log/kubernetes"
}

data "ignition_file" "cni_plugin_tgz" {
  filesystem = "root"
  path       = "/opt/cni/cni-plugins-linux.tgz"
  mode       = 500

  source {
    source       = local.binaries["cni_plugin"].source
    verification = local.binaries["cni_plugin"].checksum
  }
}

data "ignition_file" "kubernetes_env" {
  path       = "/etc/default/kubernetes.env"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/services/kubernetes.env.tpl", {
      kubelet_image_repo = local.containers["kubelet"].repo
      kubelet_image_tag  = local.containers["kubelet"].tag
      kubectl_image_repo = local.containers["kubectl"].repo
      kubectl_image_tag  = local.containers["kubectl"].tag
      cfssl_image_repo   = local.containers["cfssl"].repo
      cfssl_image_tag    = local.containers["cfssl"].tag
      cloud_provider     = local.cloud_config.provider
      network_plugin     = var.network_plugin
    })
  }
}

data "ignition_file" "init_configs_sh" {
  path       = "${local.opt_path}/bin/init-configs"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/init-configs.sh")
  }
}

data "ignition_file" "init_addons_sh" {
  count = var.control_plane ? 1 : 0

  path       = "${local.opt_path}/bin/init-addons"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/init-addons.sh")
  }
}

data "ignition_systemd_unit" "kubeinit_configs" {
  name    = "kubeinit-configs.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubeinit-configs.service.tpl", {})
}

data "ignition_systemd_unit" "kubeinit_addons" {
  count = var.control_plane ? 1 : 0

  name    = "kubeinit-addons.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubeinit-addons.service.tpl", {
    path = "${local.etc_path}/addons"
  })
}
