output "endpoints" {
  value = ["${data.template_file.etcd_endpoints.*.rendered}"]
}

output "ca_cert_pem" {
  value     = "${module.etcd_root_ca.cert_pem}"
  sensitive = true
}

output "client_cert_pem" {
  value     = "${module.etcd_client_cert.cert_pem}"
  sensitive = true
}

output "client_key_pem" {
  value     = "${module.etcd_client_cert.private_key_pem}"
  sensitive = true
}
