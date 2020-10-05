output "webhook_kubeconfig_path" {
  value = module.ignition_iam_auth.kubeconfig_path
}

output "ignitions_files" {
  value = module.ignition_iam_auth.files
}
