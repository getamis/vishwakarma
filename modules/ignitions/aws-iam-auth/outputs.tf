output "systemd_units" {
  value = [
  ]
}

output "files" {
  value = [
    data.ignition_file.aws_iam_auth_key_pem.rendered,
    data.ignition_file.aws_iam_auth_cert_pem.rendered,
    data.ignition_file.kubeconfig.rendered
  ]
}

output "kubeconfig_path" {
  value = var.webhook_kubeconfig_path
}
