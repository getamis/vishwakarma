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
