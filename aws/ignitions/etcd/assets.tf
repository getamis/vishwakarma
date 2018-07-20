data "template_file" "etcd" {
  template = "${file("${path.module}/resources/dropins/40-etcd-cluster.conf")}"

  vars = {
    certs_path          = "${var.certs_path}"
    container_image_url = "${var.container["image_path"]}"
    container_image_tag = "${var.container["image_tag"]}"
    client_port         = "${var.client_port}"
    peer_port           = "${var.peer_port}"
    cluster_name        = "${var.name}"
    scheme              = "https"
    discovery_service   = "${var.discovery_service}"
  }
}

data "ignition_systemd_unit" "etcd" {
  name    = "etcd-member.service"
  enabled = true

  dropin = [
    {
      name    = "40-etcd-cluster.conf"
      content = "${data.template_file.etcd.rendered}"
    },
  ]
}
