output "bastion_public_ip" {
  value = module.network.bastion_public_ip
}

output "ignition_s3_bucket" {
  value = module.kubernetes.s3_bucket
}

output "oidc_s3_bucket" {
  value = aws_s3_bucket.oidc.id
}

output "oidc_issuer_pub" {
  value = module.kubernetes.oidc_issuer_pubkey
}

output "tls_crt" {
  value = module.pod_identity_webhook_cert.cert_pem
}

output "tls_key" {
  value = module.pod_identity_webhook_cert.private_key_pem
}