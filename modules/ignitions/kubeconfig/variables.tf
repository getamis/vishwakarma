variable "config_path" {
  description = "(Required) The path of kubeconfig."
  type        = string
  default     = "/etc/kubernetes/admin.conf"
}

variable "endpoint" {
  description = "(Required) The endpoint of Kubernetes API server."
  type        = string
  default     = "https://127.0.0.1:6443"
}

variable "cluster" {
  description = "Name of the cluster."
  type        = string
  default     = "kubernetes"
}

variable "context" {
  description = "(Required) Name of the context."
  type        = string
  default     = "kubernetes-admin@kubernetes"
}

variable "user" {
  description = "(Required) Name of the user."
  type        = string
  default     = "kubernetes-admin"
}

variable "certificates" {
  description = "The kubernetes certificates."
  type        = map(string)
  default = {
    ca_cert          = ""
    client_cert      = ""
    client_key       = ""
    client_cert_path = ""
    client_key_path  = ""
    token            = ""
  }
}

variable "content" {
  description = "The content of the kubeconfig file."
  type        = string
  default     = ""
}
