output "systemd_units" {
  value = [
    data.ignition_systemd_unit.etcd_service.rendered,
    #data.ignition_systemd_unit.etcd_data.rendered
  ]
}

output "files" {
  value = [
    data.ignition_file.etcd_env.rendered,
    data.ignition_file.etcd_ca.rendered,
    data.ignition_file.etcd_client_cert.rendered,
    data.ignition_file.etcd_client_key.rendered,
    data.ignition_file.etcd_server_cert.rendered,
    data.ignition_file.etcd_server_key.rendered,
    data.ignition_file.etcd_peer_cert.rendered,
    data.ignition_file.etcd_peer_key.rendered
  ]
}