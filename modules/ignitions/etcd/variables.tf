variable "name" {
  type = string
}

variable "containers" {
  description = "Desired containers(etcd) repo and tag."
  type = map(object({
    repo = string
    tag  = string
  }))
  default = {}
}

variable "cloud_provider" {
  description = "The name of public cloud."
  type        = string
  default     = "aws"
}

variable "certs" {
  description = "The etcd certificates."
  type        = map(string)
  default     = {}
}

variable "cert_file_owner" {
  type = object({
    uid = number
    gid = number
  })

  default = {
    uid = 232
    gid = 232
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

variable "data_path" {
  type    = string
  default = "/var/lib/etcd"
}

variable "device_name" {
  type = string
}
