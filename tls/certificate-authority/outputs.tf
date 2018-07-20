output "algorithm" {
  value = "${var.self_signed ? join("", tls_private_key.ca.*.algorithm) : ""}"
}

output "rsa_bits" {
  value = "${var.self_signed ? var.rsa_bits : 0}"
}

output "private_key_pem" {
  value = "${var.self_signed ? join("", tls_private_key.ca.*.private_key_pem) : ""}"

  sensitive = true
}

output "cert_pem" {
  value = "${var.self_signed ? join("", tls_self_signed_cert.ca.*.cert_pem) : file(var.ca_cert_path)}"

  sensitive = true
}
