output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.kube_addon_manager.id}",
  ]
}

output "files" {
  value = []
}
