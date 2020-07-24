locals {
  certificates = merge({
    ca_cert          = ""
    client_cert      = ""
    client_key       = ""
    client_cert_path = ""
    client_key_path  = ""
    token            = ""
  }, var.certificates)
}
