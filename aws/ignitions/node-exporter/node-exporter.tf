data "template_file" "node_exporter" {
  template = "${file("${path.module}/resources/services/node-exporter.service")}"

  vars {
    listen_address = "${var.listen_address}:${var.listen_port}"
  }
}

data "ignition_systemd_unit" "node_exporter" {
  name    = "node-exporter.service"
  enabled = true
  content = "${data.template_file.node_exporter.rendered}"
}
