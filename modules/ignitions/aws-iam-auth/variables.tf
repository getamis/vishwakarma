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

variable "aws_iam_auth_ca" {
  description = "Certificate for verifying the AWS iam authenticator webhook"
  type        = string
}

variable "aws_iam_auth_crt_pem" {
  description = "AWS iam authenticator webhook tls crt"
  type        = string
}

variable "aws_iam_auth_key_pem" {
  description = "AWS iam authenticator webhook tls key"
  type        = string
}
