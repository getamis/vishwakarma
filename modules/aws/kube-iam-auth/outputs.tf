output "files" {
  value = module.ignition_iam_auth.files
}

output "webhook_kubeconfig_path" {
  value = module.ignition_iam_auth.kubeconfig_path
}

output "webhook_cert" {
  sensitive = true
  value     = module.webhook_cert.cert_pem
}

output "webhook_cert_key" {
  sensitive = true
  value     = module.webhook_cert.private_key_pem
}

output "oidc_issuer_pub_key" {
  sensitive = true
  value     = tls_private_key.oidc_issuer.public_key_pem
}

output "oidc_issuer_pri_key" {
  sensitive = true
  value     = tls_private_key.oidc_issuer.private_key_pem
}

output "oidc_s3_bucket" {
  value = aws_s3_bucket.oidc.id
}

output "oidc_issuer" {
  value = "https://s3-${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.oidc.id}"
}
