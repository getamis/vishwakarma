resource "tls_private_key" "oidc_issuer" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
