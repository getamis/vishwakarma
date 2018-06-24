variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = ""
}

variable "vpc_cidr_block" {
  description = "The CIDR block AWS VPC"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "exist_vpc_id" {
  description = "The exist AWS VPC id for EKS cluster"
  type        = "string"
}

variable "exist_subnet_ids" {
  description = "The exist AWS subnet ids for EKS cluster"
  type        = "list"
}

variable "phase" {
  description = "Specific which phase service will host"
  type        = "string"
  default     = "dev"
}

variable "project" {
  description = "Specific which project service will host"
  type        = "string"
  default     = "vishwakarma"
}

variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}

variable "lb_sg_ids" {
  type    = "list"
  default = []
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
