output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.kubelet.id}"
  ]
}


output "files" {
  value = [
    "${data.ignition_file.client_ca_file.id}",
    "${data.ignition_file.kubelet_env.id}",
    "${data.ignition_file.kubelet_json.id}"
  ]
}
