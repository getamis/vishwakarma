output "endpoint" {
  value = "https://${aws_elb.master_internal.dns_name}"
}

output "master_sg_id" {
  value = local.master_sg_id
}

output "default_role_name" {
  value = aws_iam_role.master.name
}

output "kubernetes_ca_cert" {
  sensitive = true
  value     = module.kubernetes_ca.cert_pem
}

output "service_account_pub_key" {
  sensitive = true
  value     = module.service_account.public_key_pem
}

output "tls_bootstrap_token_id" {
  sensitive = true
  value     = random_id.bootstrap_token_id.hex
}

output "tls_bootstrap_token_secret" {
  sensitive = true
  value     = random_id.bootstrap_token_secret.hex
}
