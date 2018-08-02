output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.iscsi.id}",
  ]
}

output "files" {
  value = []
}
