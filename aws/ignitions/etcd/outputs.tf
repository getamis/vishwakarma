output "systemd_units" {
  value = [
    "${data.ignition_systemd_unit.etcd.id}",
  ]
}

output "files" {
  value = [
    "${data.ignition_file.etcd_ca.id}",
    "${data.ignition_file.etcd_client_cert.id}",
    "${data.ignition_file.etcd_client_key.id}",
    "${data.ignition_file.etcd_server_cert.id}",
    "${data.ignition_file.etcd_server_key.id}",
    "${data.ignition_file.etcd_peer_cert.id}",
    "${data.ignition_file.etcd_peer_key.id}",
  ]
}
