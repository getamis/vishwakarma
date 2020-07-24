output "endpoints" {
  value = [
    for instance_ip in aws_instance.etcd.*.private_ip :
    "https://ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}:${local.client_port}"
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
