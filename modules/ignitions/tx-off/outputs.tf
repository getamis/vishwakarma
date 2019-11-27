output "systemd_units" {
  value = [
    data.ignition_systemd_unit.tx_off.rendered
  ]
}

output "files" {
  value = []
}
