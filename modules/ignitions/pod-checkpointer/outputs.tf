output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.pod_checkpointer_yaml.id}",
  ]
}
