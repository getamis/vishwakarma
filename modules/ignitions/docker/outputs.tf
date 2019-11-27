output "systemd_units" {
  value = [
    data.ignition_systemd_unit.docker_dropin.rendered
  ]
}

output "files" {
  value = []
}
