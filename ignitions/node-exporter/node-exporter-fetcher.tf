data "template_file" "node_exporter_fetcher" {
  template = "${file("${path.module}/resources/services/node-exporter-fetcher.service")}"

  vars {
    version = "${var.node_exporter_version}"
  }
}

data "ignition_systemd_unit" "node_exporter_fetcher" {
  name    = "node-exporter-fetcher.service"
  enabled = true
  content = "${data.template_file.node_exporter_fetcher.rendered}"
}
