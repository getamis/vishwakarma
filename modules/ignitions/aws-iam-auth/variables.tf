variable "state_path" {
  description = "Persisted TLS certificate and keys."
  type        = string
  default     = "/var/aws-iam-authenticator"
}

variable "server_port" {
  description = "Localhost port where the server will serve the /authenticate endpoint"
  type        = number
  default     = 21362
}

variable "webhook_kubeconfig_path" {
  description = "A path for using iam aws authenticator to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/aws-iam-authenticator"
}

variable "webhook_kubeconfig_ca" {
  description = "A certificate for verifying the remote service."
  type        = string
  default     = ""
}
