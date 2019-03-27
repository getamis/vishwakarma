output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.node_exporter.id}",
    "${data.ignition_systemd_unit.node_exporter_fetcher.id}",
  ]
}

output "files" {
  value = []
}
