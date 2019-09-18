variable "name" {
  type = string
}

variable "cert_file_owner" {
  type = object({
    uid = number
    gid = number
  })

  default = {
    uid = 232
    git = 232
  }
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

variable "data_path" {
  type    = string
  default = "/var/lib/etcd"
}

variable "container" {
  type = map(string)

  default = {
    image_path = "quay.io/coreos/etcd"
    image_tag  = "v3.4.0"
  }
}
