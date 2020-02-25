data "ignition_file" "etcd_wrapper_sh" {
  filesystem = "root"
  path       = "/opt/etcd/etcd-wrapper.sh"
  mode       = 500

  content {
    content = "${file("${path.module}/files/etcd-wrapper.sh")}"
  }
}

data "template_file" "etcd_env" {
  template = file("${path.module}/templates/etcd.env.tpl")

  vars = {
    image_url         = var.container["image_path"]
    image_tag         = var.container["image_tag"]
    user_id           = var.cert_file_owner["uid"]
    cluster_name      = var.name
    certs_path        = var.certs_path
    data_path         = var.data_path
    discovery_service = var.discovery_service
    scheme            = "https"
    client_port       = var.client_port
    peer_port         = var.peer_port
  }
}

data "ignition_file" "etcd_env" {
  filesystem = "root"
  path       = "/etc/etcd/etcd.env"
  mode       = 420

  content {
    content = data.template_file.etcd_env.rendered
  }
}

data "template_file" "etcd_service" {
  template = file("${path.module}/templates/etcd.service.tpl")
}

data "ignition_systemd_unit" "etcd_service" {
  name    = "etcd.service"
  enabled = true
  content = data.template_file.etcd_service.rendered
}
