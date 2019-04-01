data "template_file" "cni_plugin_fetcher" {
  template = "${file("${path.module}/resources/services/cni-plugin-fetcher.service")}"

  vars {
    cni_plugin_version = "${var.cni_plugin_version}"
  }
}

data "ignition_systemd_unit" "cni_plugin_fetcher" {
  name    = "cni-plugin-fetcher.service"
  enabled = true
  content = "${data.template_file.cni_plugin_fetcher.rendered}"
}
