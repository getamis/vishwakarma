variable "name" {
  description = "(Required) Name of the cluster."
  type        = string
}

variable "certs_validity_period_hours" {
  description = "Validity period of the self-signed certificates (in hours). Default is 10 years."
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}

variable "webhook_service_name" {
  description = "The Pod identity service name"
  type        = string
  default     = "pod-identity-webhook"
}

variable "webhook_service_namespace" {
  description = "The Pod identity service namespace."
  type        = string
  default     = "kube-system"
}

variable "webhook_kubeconfig_dir_path" {
  description = "(Optional) A path for using customize machine to authenticate to a Kubernetes cluster."
  type        = string
  default     = "/etc/kubernetes/config/aws-iam-authenticator"
}

variable "ignition_s3_bucket" {
  description = <<EOF
    (Optional) Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
  type        = string
}

variable "oidc_s3_bucket" {
  description = "Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters."
  type        = string
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
