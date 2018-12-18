output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.policy_yaml.id}",
  ]
}