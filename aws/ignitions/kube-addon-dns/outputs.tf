output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.kube_dns_yaml.id}",
  ]
}
