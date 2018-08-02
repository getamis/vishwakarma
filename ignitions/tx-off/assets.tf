data "template_file" "tx_off" {
  template = "${file("${path.module}/resources/services/tx-off.service")}"
}

data "ignition_systemd_unit" "tx_off" {
  name    = "tx-off.service"
  enabled = true
  content = "${data.template_file.tx_off.rendered}"
}
