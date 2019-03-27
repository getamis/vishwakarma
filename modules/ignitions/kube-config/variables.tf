variable "content" {
  type        = "string"
  default     = ""
  description = "The content of the kubeconfig file."
}

variable "name" {
  type        = "string"
  default     = ""
  description = "(Required) Name of the cluster."
}

variable "api_server_endpoint" {
  type        = "string"
  default     = ""
  description = "(Required) The endpoint of the API server."
}

variable "kube_certs" {
  type = "map"

  default = {
    ca_cert_pem      = ""
    kubelet_key_pem  = ""
    kubelet_cert_pem = ""
  }
}
