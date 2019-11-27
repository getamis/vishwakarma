output "systemd_units" {
  value = []
}

output "files" {
  value = [
    data.ignition_file.ntp_dropin.rendered
  ]
}
