locals {
  algorithm = "RSA"
}

resource "tls_private_key" "ca" {
  count = var.self_signed ? 1 : 0

  algorithm = local.algorithm
  rsa_bits  = var.rsa_bits
}

resource "tls_self_signed_cert" "ca" {
  count = var.self_signed ? 1 : 0

  key_algorithm   = tls_private_key.ca[count.index].algorithm
  private_key_pem = tls_private_key.ca[count.index].private_key_pem

  subject {
    common_name  = var.cert_config["common_name"]
    organization = var.cert_config["organization"]
  }

  is_ca_certificate     = true
  validity_period_hours = var.cert_config["validity_period_hours"]

  allowed_uses = var.ca_uses
}
