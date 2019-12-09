variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "key_pair_name" {
  description = "The key pair name for access bastion ec2"
  type        = string
}

variable "project" {
  description = "(Optional) project name, used to compose the resource name"
  type        = string
  default     = "vishwakarma"
}

variable "phase" {
  description = "(Optional) phase name, used to compose the resource name"
  type        = string
  default     = "test"
}

variable "kubernetes_version" {
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
  type        = string
  default     = "1.14"
}

variable "endpoint_public_access" {
  description = "(Optional) kubernetes apiserver endpoint"
  type        = bool
  default     = true
}

variable "worker_groups" {
  description = "The worker groups's name for generating role"
  type        = list(string)
  default     = ["on-demand", "spot"]
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
