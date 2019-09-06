output "systemd_units" {
  value = [
    data.ignition_systemd_unit.kubelet.rendered
  ]
}

output "files" {
  value = [
    data.ignition_file.kubelet_env.rendered
  ]
}
