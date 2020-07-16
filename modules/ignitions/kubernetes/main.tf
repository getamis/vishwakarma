locals {
  kubernetes_minior_version = parseint(split(".", var.version)[1], 10)

  root_path        = "/etc/kubernetes"
  mainifest_path   = "/etc/kubernetes/manifests"
  pki_path         = "/etc/kubernetes/pki"
  etcd_pki_path    = "${local.pki_path}/etcd"
  addons_path      = "/etc/kubernetes/addons"
  config_path      = "/etc/kubernetes/config"
  log_path         = "/var/log/kubernetes"
  opt_path         = "/opt/kubernetes"
  kubelet_var_path = "/var/lib/kubelet"
}

data "ignition_file" "kubernetes_env" {
  path       = "/etc/default/kubernetes.env"
  filesystem = "root"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/services/kubernetes.env.tpl", {
      kubelet_url         = local.binaries["kubelet"].url
      kubelet_checksum    = local.binaries["kubelet"].checksum
      kubectl_url         = local.binaries["kubectl"].url
      kubectl_checksum    = local.binaries["kubectl"].checksum
      cni_plugin_url      = local.binaries["cni_plugin"].url
      cni_plugin_checksum = local.binaries["cni_plugin"].checksum
      cfssl_image_repo    = local.containers["cfssl"].repo
      cfssl_image_tag     = local.containers["cfssl"].tag

      cloud_provider = local.cloud_config.provider
      network_plugin = var.network_plugin
    })
  }
}

data "ignition_file" "install_sh" {
  path       = "${local.opt_path}/bin/install.sh"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/install.sh")
  }
}

data "ignition_file" "init_sh" {
  count = var.control_plane ? 1 : 0
  
  path       = "${local.opt_path}/bin/init.sh"
  filesystem = "root"
  mode       = 500

  content {
    content = file("${path.module}/files/script/init.sh")
  }
}

data "ignition_systemd_unit" "kubernetes_install" {
  name    = "kubernetes-install.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubernetes-install.service.tpl", {})
}

data "ignition_systemd_unit" "kubernetes_init" {
  count = var.control_plane ? 1 : 0

  name    = "kubernetes-init.service"
  enabled = true
  content = templatefile("${path.module}/templates/services/kubernetes-init.service.tpl", {
    path = local.addons_path
  })
}