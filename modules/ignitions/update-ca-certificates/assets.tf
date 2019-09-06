data "template_file" "update_ca_certificates_dropin" {
  template = file("${path.module}/resources/dropins/10-always-update-ca-certificates.conf")
}

data "ignition_systemd_unit" "update_ca_certificates_dropin" {
  name    = "update-ca-certificates.service"
  enabled = true

  dropin {
      name    = "10-always-update-ca-certificates.conf"
      content = data.template_file.update_ca_certificates_dropin.rendered
  }
}
