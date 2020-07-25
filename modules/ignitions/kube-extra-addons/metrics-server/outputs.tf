output "files" {
  value = [
    data.ignition_file.metrics_server_components.rendered,
  ]
}

