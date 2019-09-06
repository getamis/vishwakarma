output "systemd_units" {
  value = [
    data.ignition_systemd_unit.iscsi.rendered
  ]
}

output "files" {
  value = []
}
