output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.tx_off.id}",
  ]
}

output "files" {
  value = []
}
