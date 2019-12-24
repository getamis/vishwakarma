output "systemd_units" {
  value = []
}

output "files" {
  value = [
    data.ignition_file.coredns_yaml.rendered
  ]
}
