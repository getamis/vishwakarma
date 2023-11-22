output "endpoints" {
  value = [
    for etcd_ip in flatten(aws_network_interface.etcd.*.private_ips) :
    "https://ip-${replace(etcd_ip, ".", "-")}.${local.discovery_service}:${local.client_port}"
  ]
}

output "ca_cert" {
  sensitive = true
  value     = module.etcd_ca.cert_pem
}

output "ca_key" {
  sensitive = true
  value     = module.etcd_ca.private_key_pem
}

output "default_role_name" {
  value = aws_iam_role.etcd.name
}
