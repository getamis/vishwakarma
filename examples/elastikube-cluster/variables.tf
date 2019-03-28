variable "aws_region" {
  type        = "string"
  default     = "us-west-2"
  description = "(Optional) The AWS region"
}

variable "service_cidr" {
  type        = "string"
  default     = "172.16.0.0/13"
  description = "(Optional) The Kubernetes service CIDR."
}

variable "cluster_cidr" {
  type        = "string"
  default     = "172.24.0.0/13"
  description = "(Optional) The Kubernetes cluster CIDR."
}

variable "key_pair_name" {
  type        = "string"
  description = "The ssh key name for all instance, e.g. bastion, master, etcd, worker"
}

variable "project" {
  type = "string"
  default = "elastikube"
  description = "(Optional) project name, used to compose the resource name"  
}

variable "phase" {
  type = "string"
  default = "test"
  description = "(Optional) phase name, used to compose the resource name"
}

variable "endpoint_public_access" {
  default = false
  description = "(Optional) kubernetes apiserver endpoint"
}

variable "extra_tags" {
  type        = "map"
  default     = {}
  description = "Extra AWS tags to be applied to created resources."
}
