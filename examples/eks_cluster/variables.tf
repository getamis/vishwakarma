variable "bastion_key_name" {
  description = "The key for access bastion"
  type        = "string"
  default     = "vishwakarma"
}

variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = "us-east-1"
}

variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
