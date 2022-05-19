module "webhook_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = var.name
    organization          = var.name
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "webhook_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = module.webhook_ca.algorithm
    key_pem   = module.webhook_ca.private_key_pem
    cert_pem  = module.webhook_ca.cert_pem
  }

  cert_config = {
    common_name           = "pod-identity-webhook"
    organization          = var.name
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = [
    var.service_name,
    "${var.service_name}.${var.namespace}",
    "${var.service_name}.${var.namespace}.svc",
    "${var.service_name}.${var.namespace}.svc.local"
  ]

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  self_signed = true
}