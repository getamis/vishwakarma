variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = "us-west-2"
}

variable "key_pair_name" {
  description = "The key pair name for access bastion ec2"
  type        = "string"
}

variable "project" {
  type = "string"
  default = "vishwakarma"
  description = "(Optional) project name, used to compose the resource name"  
}

variable "phase" {
  type = "string"
  default = "test"
  description = "(Optional) phase name, used to compose the resource name"
}

variable "kubernetes_version" {
  type        = "string"
  default     = "1.12.7"
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "endpoint_public_access" {
  default = true
  description = "(Optional) kubernetes apiserver endpoint"
}

variable "worker_groups" {
  description = "The worker groups's name for generating role"
  type        = "list"
  default     = ["on-demand", "spot"]
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
