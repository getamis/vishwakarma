variable "validity_period_hours" {
  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
EOF
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default     = 26280
}

variable "service_cidr" {
  type    = string
  default = "172.16.0.0/16"

  description = <<EOF
(Optional) This declares the IP range to assign Kubernetes service cluster IPs in CIDR notation.
EOF
}
