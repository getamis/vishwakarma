variable "algorithm" {
  type    = string
  default = "RSA"
}

variable "rsa_bits" {
  type    = number
  default = 2048
}

variable "ca_config" {
  description = "Certificate Authority configuration"
  type        = map(string)
  default = {
    algorithm = "RSA"
    key_pem   = ""
    cert_pem  = ""
  }
}

variable "cert_config" {
  description = "Certificate configuration"
  type        = map(string)
  default = {
    common_name           = ""
    organization          = ""
    validity_period_hours = "26280"
  }
}

variable "cert_hostnames" {
  type    = list(string)
  default = []
}

variable "cert_ip_addresses" {
  type    = list(string)
  default = []
}

variable "cert_uses" {
  type    = list(string)
  default = []
}

variable "self_signed" {
  description = <<EOF
If set to true, self-signed certificates are generated.
If set to false, only the passed CA and client certs are being used.
EOF
  type        = bool
}
