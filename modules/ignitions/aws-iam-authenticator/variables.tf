variable "state_path" {
  type        = "string"
  default     = "/var/aws-iam-authenticator"
  description = "Persisted TLS certificate and keys."
}

variable "server_port" {
  default     = 21362
  description = "Localhost port where the server will serve the /authenticate endpoint"
}

variable "webhook_kubeconfig_path" {
  type        = "string"
  default     = "/etc/kubernetes/aws-iam-authenticator"
  description = "A path for using iam aws authenticator to authenticate to a Kubernetes cluster."
}

variable "webhook_kubeconfig_ca" {
  type        = "string"
  default     = ""
  description = "A certificate for verifying the remote service."
}
