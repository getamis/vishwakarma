output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.kube_proxy_yaml.id}",
  ]
}
