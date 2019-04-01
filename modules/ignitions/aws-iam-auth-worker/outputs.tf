output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.aws_iam_authenticator.id}"
  ]
}


output "files" {
  value = []
}