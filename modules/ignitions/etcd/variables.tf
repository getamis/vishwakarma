variable "name" {
  type = string
}

variable "discovery_service" {
  type = string
}

variable "client_port" {
  default = 2379
}

variable "peer_port" {
  default = 2380
}

variable "certs_path" {
  type    = string
  default = "/etc/ssl/etcd"
}

variable "certs_config" {
  type = map(string)

  default = {
    # ca_cert_pem     = ""
    # client_key_pem  = ""
    # client_cert_pem = ""
    # server_key_pem  = ""
    # server_cert_pem = ""
    # peer_key_pem    = ""
    # peer_cert_pem   = ""
  }
}

variable "container" {
  type = map(string)

  default = {
    image_path = "quay.io/coreos/etcd"
    image_tag  = "v3.3.15"
  }
}
