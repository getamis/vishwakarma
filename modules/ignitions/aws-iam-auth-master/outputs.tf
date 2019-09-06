output "systemd_units" {
  value = [
    data.ignition_systemd_unit.provision.rendered
  ]
}

output "files" {
  value = [
    data.ignition_file.kubeconfig.rendered
  ]
}

output "kubeconfig_path" {
  value = var.webhook_kubeconfig_path
}
