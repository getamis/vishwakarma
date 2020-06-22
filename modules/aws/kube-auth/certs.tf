module "pod_identity_webhook_root_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = var.name
    organization          = var.name
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "pod_identity_webhook_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = module.pod_identity_webhook_root_ca.algorithm
    key_pem   = module.pod_identity_webhook_root_ca.private_key_pem
    cert_pem  = module.pod_identity_webhook_root_ca.cert_pem
  }

  cert_config = {
    common_name           = "pod-identity-webhook"
    organization          = var.name
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = ["${var.pod_identity_webhook_service_name}.${var.pod_identity_webhook_service_namespace}.svc"]

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  self_signed = true
}