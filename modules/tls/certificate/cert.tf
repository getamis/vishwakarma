locals {
  algorithm = "RSA"
}

resource "tls_private_key" "pk" {
  count = var.self_signed ? 1 : 0

  algorithm = local.algorithm
  rsa_bits  = var.rsa_bits
}

resource "tls_cert_request" "request" {
  count = var.self_signed ? 1 : 0

  key_algorithm   = tls_private_key.pk[count.index].algorithm
  private_key_pem = tls_private_key.pk[count.index].private_key_pem

  subject {
    common_name  = var.cert_config["common_name"]
    organization = var.cert_config["organization"]
  }

  dns_names = distinct(var.cert_hostnames)

  ip_addresses = distinct(var.cert_ip_addresses)
}

resource "tls_locally_signed_cert" "cert" {
  count = var.self_signed ? 1 : 0

  cert_request_pem = tls_cert_request.request[count.index].cert_request_pem

  ca_key_algorithm      = var.ca_config["algorithm"]
  ca_private_key_pem    = var.ca_config["key_pem"]
  ca_cert_pem           = var.ca_config["cert_pem"]
  validity_period_hours = var.cert_config["validity_period_hours"]

  allowed_uses = concat(list("key_encipherment"), var.cert_uses)
}
