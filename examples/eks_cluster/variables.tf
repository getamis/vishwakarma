variable "bastion_key_name" {
  description = "The key pair name for access bastion ec2"
  type        = "string"
}

variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = "us-west-2"
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
