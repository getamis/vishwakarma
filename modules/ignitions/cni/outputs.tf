output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.cni_fetcher.id}",
    "${data.ignition_systemd_unit.cni_plugin_fetcher.id}",
  ]
}

output "files" {
  value = []
}
