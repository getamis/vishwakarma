variable "content" {
  description = "The content of the kubeconfig file."
  type        = string
  default     = ""
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "(Required) Name of the cluster."
  type        = string
  default     = ""
}

variable "api_server_endpoint" {
  description = "(Required) The endpoint of the API server."
  type        = string
  default     = ""
}

variable "kube_certs" {
  description = "The kubernetes certificate"
  type        = map(string)
  default     = {
    ca_cert_pem      = ""
    kubelet_key_pem  = ""
    kubelet_cert_pem = ""
  }
}
