variable "ignition_s3_bucket" {
  description = "The Kubernetes ignition s3 bucket"
  type        = string
}

variable "kubeconfig_s3_key" {
  description = "The kubeconfig s3 key name"
  type        = string
  default     = "admin.conf"
}

variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
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
  default     = "k8s"
}

variable "service" {
  description = "(Optional) which service provide by this service"
  type        = string
  default     = "kubernetes"
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA."
  type        = string
}

variable "oidc_issuer" {
  description = "Domain name of the S3 bucket (*.s3.amazonaws.com)."
  type        = string
}