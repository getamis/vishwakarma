variable "certs_validity_period_hours" {
  description = <<EOF
    Validity period of the self-signed certificates (in hours). Default is 10 years.
EOF
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}

variable "name" {
  description = " (Required) Name of the cluster."
  type        = string
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

variable "webhook_kubeconfig_ca" {
  description = "The Kubernetes certificate authority"
  type        = string
}

variable "webhook_kubeconfig_path" {
  description = "(Optional) A path for using customize machine to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/aws-iam-authenticator"
}

variable "ignition_s3_bucket" {
  description = <<EOF
    (Optional) Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
  type        = string
}

variable "oidc_s3_bucket" {
  description = <<EOF
    Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
EOF
  type        = string
}

variable "oidc_issuer_pubkey" {
  description = "The Kubernetes service account public key"
  type        = string
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}