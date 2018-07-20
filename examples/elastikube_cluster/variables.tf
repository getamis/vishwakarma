variable "aws_region" {
  type        = "string"
  default     = "ap-southeast-1"
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

variable "extra_tags" {
  type        = "map"
  default     = {}
  description = "Extra AWS tags to be applied to created resources."
}
