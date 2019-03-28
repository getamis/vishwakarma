output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.max_user_watches.id}",
  ]
}
