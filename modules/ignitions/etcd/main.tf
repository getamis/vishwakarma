locals {
  certs_path = "/etc/ssl/etcd"
}

data "ignition_file" "etcd_wrapper_sh" {
  filesystem = "root"
  path       = "/opt/etcd/bin/etcd-wrapper.sh"
  mode       = 500

  content {
    content = "${file("${path.module}/scripts/etcd-wrapper.sh")}"
  }
}

data "ignition_file" "etcd_env" {
  filesystem = "root"
  path       = "/etc/etcd/etcd.env"
  mode       = 420

  content {
    content = templatefile("${path.module}/templates/etcd.env.tpl", {
      image_repo        = local.container["etcd"].repo
      image_tag         = local.container["etcd"].tag
      cloud_provider    = var.cloud_provider
      user_id           = var.cert_file_owner["uid"]
      cluster_name      = var.name
      certs_path        = local.certs_path
      data_path         = var.data_path
      discovery_service = var.discovery_service
      scheme            = "https"
      client_port       = var.client_port
      peer_port         = var.peer_port
    })
  }
}

data "ignition_systemd_unit" "etcd_service" {
  name    = "etcd.service"
  enabled = true
  content = templatefile("${path.module}/templates/etcd.service.tpl", {})
}
