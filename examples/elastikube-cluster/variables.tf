variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "service_cidr" {
  description = "(Optional) The Kubernetes service CIDR."
  type        = string
  default     = "172.16.0.0/13"
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
  default     = "v1.14.9"
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
  default     = false
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
