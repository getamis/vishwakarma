variable "rsa_bits" {
  default = 2048
}

variable "cert_config" {
  description = "Certificate configuration"
  type        = map(string)
  default     = {
    common_name           = ""
    organization          = ""
    validity_period_hours = "26280"
  }
}

variable "ca_cert_path" {
  description = "external CA certificate"
  type        = string
  default     = "/dev/null"
}

variable "ca_uses" {
  type    = list(string)
  default = [
    "key_encipherment",
    "digital_signature",
    "cert_signing"
  ]
}

variable "self_signed" {
  description = <<EOF
If set to true, self-signed certificates are generated.
If set to false, only the passed CA and client certs are being used.
EOF
  type        = bool
}
