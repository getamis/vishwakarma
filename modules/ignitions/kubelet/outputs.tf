output "systemd_units" {
  value = [
    data.ignition_systemd_unit.kubelet.rendered
  ]
}

output "files" {
  value = [
    data.ignition_file.kubelet_env.rendered,
    data.ignition_file.eni_max_pods_txt.rendered,
    data.ignition_file.get_max_pods_sh.rendered
  ]
}
