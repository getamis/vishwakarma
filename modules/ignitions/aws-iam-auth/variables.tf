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

variable "kubeconfig_dir_path" {
  description = "A path for using iam aws authenticator to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/config/aws-iam-authenticator"
}

variable "auth_ca_cert" {
  description = "Certificate for verifying the AWS iam authenticator webhook"
  type        = string
}

variable "auth_cert" {
  description = "AWS iam authenticator webhook tls cert"
  type        = string
}

variable "auth_cert_key" {
  description = "AWS iam authenticator webhook tls cert key"
  type        = string
}
