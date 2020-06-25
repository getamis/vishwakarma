variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "oidc_api_audiences" {
  description = "the OIDC authenticator pre-introduction of API audiences"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "ignition_s3_bucket" {
  description = "The Kubernetes ignition s3 bucket"
  type        = string
}

variable "kubeconfig_s3_key" {
  description = "The kubeconfig s3 key name"
  type        = string
  default     = "kubeconfig"
}

variable "oidc_s3_bucket" {
  description = "The oidc s3 bucket for IRSA"
  type        = string
}

variable "aws_iam_authenticator_image" {
  description = "The pod identity webhook image"
  type        = string
  default     = "quay.io/amis/aws-iam-authenticator:d7c0b2e"
}

variable "pod_identity_webhook_image" {
  description = "The pod identity webhook image"
  type        = string
  default     = "quay.io/amis/pod-identity-webhook:694444b"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}