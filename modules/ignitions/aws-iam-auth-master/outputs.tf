output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.provision.id}",
  ]
}

output "files" {
  value = [
    "${data.ignition_file.kubeconfig.id}",
  ]
}

output "kubeconfig_path" {
  value = "${var.webhook_kubeconfig_path}"
}
