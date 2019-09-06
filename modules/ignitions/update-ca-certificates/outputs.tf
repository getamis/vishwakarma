output "systemd_units" {
  value = [
    data.ignition_systemd_unit.update_ca_certificates_dropin.rendered
  ]
}

output "files" {
  value = []
}
