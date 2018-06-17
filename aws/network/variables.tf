variable "aws_region" {
  type        = "string"
}

variable "cidr_block" {
  description = "The CIDR block AWS VPC"
  type        = "string"
  default     = "10.0.0.0/16"
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

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
