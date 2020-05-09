variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_az_number" {
  description = "How many AZs want to be used"
  type        = string
  default     = "3"
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

variable "hyperkube_container" {
  description = "(Optional) Desired Hyperkube container to boot K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
  default = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.15.11"
  }
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "amazon-vpc"
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
