output "systemd_units" {
  value = []
}

output "files" {
  value = [
    "${data.ignition_file.kube_apiserver_yaml.id}",
    "${data.ignition_file.kube_controller_manager_yaml.id}",
    "${data.ignition_file.kube_scheduler_yaml.id}",
    "${data.ignition_file.kube_system_rbac_role_binding_yaml.id}",
    "${data.ignition_file.kube_ca_cert_pem.id}",
    "${data.ignition_file.apiserver_key_pem.id}",
    "${data.ignition_file.apiserver_cert_pem.id}",
    "${data.ignition_file.service_account_pub.id}",
    "${data.ignition_file.service_account_key.id}",
    "${data.ignition_file.etcd_ca_cert_pem.id}",
    "${data.ignition_file.etcd_client_cert_pem.id}",
    "${data.ignition_file.etcd_client_key_pem.id}",
  ]
}
