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
    data.ignition_file.service_account_pub.rendered,
    data.ignition_file.service_account_key.rendered,
    data.ignition_file.oidc_issuer_pub.rendered,
    data.ignition_file.oidc_issuer_key.rendered,
    data.ignition_file.etcd_ca_cert_pem.rendered,
    data.ignition_file.etcd_client_cert_pem.rendered,
    data.ignition_file.etcd_client_key_pem.rendered,
  ]
}

output "oidc_issuer_pubkey" {
  value = tls_private_key.oidc_issuer.public_key_pem
}