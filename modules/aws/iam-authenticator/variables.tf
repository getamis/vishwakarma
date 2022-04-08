variable "name" {
  description = "(Required) Name of the cluster."
  type        = string
  default     = "kubernetes"
}

variable "container" {
  description = "Desired container repo and tag."
  type        = map(string)
  default = {
    repo = "quay.io/amis/aws-iam-authenticator"
    tag  = "v0.5.5"
  }
}

variable "webhook_kubeconfig_dir_path" {
  description = "(Optional) A path for using customize machine to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/config/aws-iam-authenticator"
}

variable "webhook_server_port" {
  description = "Localhost port where the server will serve the /authenticate endpoint"
  type        = number
  default     = 21362
}

variable "kube_addons_dir_path" {
  description = "A path for installing addons."
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "pki_dir_path" {
  description = "Persisted TLS certificate and keys."
  type        = string
  default     = "/etc/kubernetes/pki/aws-iam-authenticator"
}

variable "certs_validity_period_hours" {
  description = "Validity period of the self-signed certificates (in hours). Default is 10 years."
  type        = string
  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
