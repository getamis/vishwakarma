output "systemd_units" {
  value = []
}

output "files" {
  value = [
    data.ignition_file.kubeconfig.rendered,
  ]
}

output "content" {
  value = coalesce(var.content, join("", data.template_file.kubeconfig.*.rendered))
}
