variable "name" {
  description = "(Optional) name, used to compose the resource name"
  type        = string
}

variable "vpc_id" {
  description = "The AWS VPC for bastion"
  type        = string
}

variable "subnet_id" {
  description = "The AWS Subnet for bastion"
  type        = string
}

variable "ami_id" {
  description = "The AWS AMI id for bastion"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The AWS instance type for bastion"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The AWS EC2 key name for bastion"
  type        = string
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources"
  type        = map(string)
  default     = {}
}
