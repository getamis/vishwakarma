resource "tls_private_key" "service_account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_private_key" "oidc_issuer" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
