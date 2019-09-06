output "systemd_units" {
  value = [
    data.ignition_systemd_unit.node_exporter.rendered,
    data.ignition_systemd_unit.node_exporter_fetcher.rendered,
  ]
}

output "files" {
  value = []
}
