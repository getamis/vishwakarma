output "private_key_pem" {
  value = "${element(concat(tls_private_key.pk.*.private_key_pem, list("")), 0)}"

  sensitive = true
}

output "cert_pem" {
  value = "${element(concat(tls_locally_signed_cert.cert.*.cert_pem, list("")), 0)}"

  sensitive = true
}
