output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.locksmithd.id}",
  ]
}

output "files" {
  value = []
}
