output "systemd_units" {
  value = module.ignition_aws_iam_authenticator.systemd_units
}

output "files" {
  value = module.ignition_aws_iam_authenticator.files
}

output "pod_identity_webhook_crt" {
  value = module.pod_identity_webhook_cert.cert_pem
}

output "pod_identity_webhook_prikey" {
  value = module.pod_identity_webhook_cert.private_key_pem
}

output "service_account_pubkey" {
  value = tls_private_key.service_account.public_key_pem
}

output "service_account_prikey" {
  value = tls_private_key.service_account.private_key_pem
}

output "oidc_issuer_pubkey" {
  value = tls_private_key.oidc_issuer.public_key_pem
}

output "oidc_issuer_prikey" {
  value = tls_private_key.oidc_issuer.private_key_pem
}

output "oidc_s3_bucket" {
  value = aws_s3_bucket.oidc.id
}

output "oidc_issuer" {
  value = "https://s3-${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.oidc.id}"
}