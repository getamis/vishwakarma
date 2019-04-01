data "template_file" "cni_fetcher" {
  template = "${file("${path.module}/resources/services/cni-fetcher.service")}"

  vars {
    cni_version        = "${var.cni_version}"
  }
}

data "ignition_systemd_unit" "cni_fetcher" {
  name    = "cni-fetcher.service"
  enabled = true
  content = "${data.template_file.cni_fetcher.rendered}"
}
