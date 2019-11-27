output "endpoints" {
  value = [
    for instance_ip in aws_instance.etcd.*.private_ip:
      "https://ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}:${local.client_port}"
  ]
}

output "ca_cert_pem" {
  value     = module.etcd_root_ca.cert_pem
  sensitive = true
}

output "client_cert_pem" {
  value     = module.etcd_client_cert.cert_pem
  sensitive = true
}

output "client_key_pem" {
  value     = module.etcd_client_cert.private_key_pem
  sensitive = true
}
