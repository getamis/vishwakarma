variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = ""
}

variable "aws_az_number" {
  description = "How many AZs want to build"
  type    = "string"
  default = "3"
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

variable "bastion_ami_id" {
  description = "The AWS AMI id for bastion"
  type        = "string"
  default     = ""
}

variable "bastion_instance_type" {
  description = "The AWS instance type for bastion"
  type        = "string"
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "The AWS EC2 key name for bastion"
  type        = "string"
}
