output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.docker_dropin.id}",
  ]
}

output "files" {
  value = []
}
