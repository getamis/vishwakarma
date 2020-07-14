resource "tls_private_key" "main" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}
