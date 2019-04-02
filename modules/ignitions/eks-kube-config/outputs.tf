output "systemd_units" {
  value = []
}


output "files" {
  value = [
    "${data.ignition_file.kubeconfig.id}",
  ]
}

output "rendered" {
  value = "${data.template_file.kubeconfig.rendered}"
}