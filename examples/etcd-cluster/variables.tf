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

variable "key_pair_name" {
  description = "The ssh key name for all instance, e.g. bastion, master, etcd, worker"
  type        = string
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

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}

variable "hostzone" {
  description = "(Optional) The cluster private hostname. If not specified, <cluster name>.com will be used."
  type        = string
  default     = ""
}

variable "reboot_strategy" {
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
  type        = string
  default     = "off"
}

variable "certs_validity_period_hours" {
  description = <<EOF
    Validity period of the self-signed certificates (in hours). Default is 10 years.
EOF
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}


variable "etcd_security_group_id" {
  description = <<EOF
    (Optional) Main security group ID of the etcd cluster.
EOF
  type        = string
  default     = ""
}
