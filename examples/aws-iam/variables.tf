variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "auth_webhook_path" {
  description = "(Optional) A path for using customize machine to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/aws-iam-authenticator"
}

variable "certs_validity_period_hours" {
  description = <<EOF
    Validity period of the self-signed certificates (in hours). Default is 3 years.
EOF
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 26280
}

variable "cluster_cidr" {
  description = "(Optional) The Kubernetes cluster CIDR."
  type        = string
  default     = "172.24.0.0/13"
}

variable "key_pair_name" {
  description = "The ssh key name for all instance, e.g. bastion, master, etcd, worker"
  type        = string
}

variable "kubernetes_version" {
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
  type        = string
  default     = "v1.15.10"
}

variable "project" {
  description = "(Optional) project name, used to compose the resource name"
  type        = string
  default     = "elastikube"
}

variable "phase" {
  description = "(Optional) phase name, used to compose the resource name"
  type        = string
  default     = "test"
}

variable "endpoint_public_access" {
  description = "(Optional) kubernetes apiserver endpoint"
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}

variable "pod_identity_webhook_service_name" {
  description = "The Pod identity service name"
  type        = string
  default     = "pod-identity-webhook"
}

variable "pod_identity_webhook_service_namespace" {
  description = "The Pod identity service namespace"
  type        = string
  default     = "kube-system"
}

variable "oidc_api_audiences" {
  description = "the OIDC authenticator pre-introduction of API audiences"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "service_cidr" {
  description = "(Optional) The Kubernetes service CIDR."
  type        = string
  default     = "172.16.0.0/13"
}
