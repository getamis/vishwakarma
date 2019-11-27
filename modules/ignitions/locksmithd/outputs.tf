output "systemd_units" {
  value = [
    data.ignition_systemd_unit.locksmithd.rendered
  ]
}

output "files" {
  value = []
}
