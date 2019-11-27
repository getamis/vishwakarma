variable "aws_az_number" {
  description = "How many AZs want to be used"
  type        = string
  default     = "3"
}

variable "cidr_block" {
  description = "The CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "phase" {
  description = "Specific which phase service will be hosted"
  type        = string
  default     = "test"
}

variable "project" {
  description = "Specific which project service will host"
  type        = string
  default     = "vishwakarma"
}

variable "bastion_ami_id" {
  description = "The AWS AMI id for bastion"
  type        = string
  default     = ""
}

variable "bastion_instance_type" {
  description = "The AWS instance type for bastion"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "The AWS EC2 key name for bastion"
  type        = string
}

variable "private_zone" {
  description = "Create a private Route53 host zone"
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources"
  type        = map(string)
  default     = {}
}
