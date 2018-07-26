variable "rsa_bits" {
  default = 2048
}

variable "cert_config" {
  type        = "map"
  description = "Certificate configuration"

  default = {
    common_name           = ""
    organization          = ""
    validity_period_hours = "26280"
  }
}

variable "ca_cert_path" {
  type        = "string"
  description = "external CA certificate"
  default     = "/dev/null"
}

variable "self_signed" {
  description = <<EOF
If set to true, self-signed certificates are generated.
If set to false, only the passed CA and client certs are being used.
EOF
}
