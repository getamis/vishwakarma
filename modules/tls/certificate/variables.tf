variable "rsa_bits" {
  default = 2048
}

variable "ca_config" {
  type        = "map"
  description = "Certificate Authority configuration"

  default = {
    algorithm = "RSA"
    key_pem   = ""
    cert_pem  = ""
  }
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

variable "cert_hostnames" {
  type    = "list"
  default = []
}

variable "cert_ip_addresses" {
  type    = "list"
  default = []
}

variable "cert_uses" {
  type    = "list"
  default = []
}

variable "self_signed" {
  description = <<EOF
If set to true, self-signed certificates are generated.
If set to false, only the passed CA and client certs are being used.
EOF
}
