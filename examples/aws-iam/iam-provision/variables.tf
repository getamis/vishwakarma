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
  default     = "admin.conf"
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

variable "environment" {
  description = "(Optional) environment name, used to compose the resource name"
  type        = string
  default     = "test"
}

variable "project" {
  description = "(Optional) project name, used to compose the resource name"
  type        = string
  default     = "getamis"
}

variable "name" {
  description = "(Optional) name, used to compose the resource name"
  type        = string
  default     = "elastikube"
}

variable "service" {
  description = "(Optional) which service provide by this service"
  type        = string
  default     = "kubernetes"
}