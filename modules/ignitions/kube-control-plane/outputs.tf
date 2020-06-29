output "systemd_units" {
  value = []
}

output "files" {
  value = [
    data.ignition_file.kube_apiserver_yaml.rendered,
    data.ignition_file.kube_controller_manager_yaml.rendered,
    data.ignition_file.kube_scheduler_yaml.rendered,
    data.ignition_file.kube_system_rbac_role_binding_yaml.rendered,
    data.ignition_file.kube_ca_cert_pem.rendered,
    data.ignition_file.apiserver_key_pem.rendered,
    data.ignition_file.apiserver_cert_pem.rendered,
    data.ignition_file.controller_manager_key_pem.rendered,
    data.ignition_file.controller_manager_cert_pem.rendered,
    data.ignition_file.service_account_pubkey.rendered,
    data.ignition_file.service_account_prikey.rendered,
    data.ignition_file.etcd_ca_cert_pem.rendered,
    data.ignition_file.etcd_client_cert_pem.rendered,
    data.ignition_file.etcd_client_key_pem.rendered,
  ]
}

output "service_account_pubkey" {
  value = tls_private_key.service_account.public_key_pem
}