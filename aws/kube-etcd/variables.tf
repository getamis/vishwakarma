variable "aws_region" {
  type        = "string"
  default     = "us-east-1"
  description = "(Optional) The AWS region"
}

variable "name" {
  type        = "string"
  description = " (Required) Name of the etcd cluster."
}

variable "role_name" {
  type    = "string"
  default = ""

  description = <<EOF
    (Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for
    the etcd nodes to make calls to AWS API operations on your behalf.
EOF
}

variable "master_security_group_id" {
  type = "string"

  description = <<EOF
    (Required) Main security group ID to use to allow communication between your etcd nodes
    and the Kubernetes control plane.
EOF
}

variable "security_group_ids" {
  type    = "list"
  default = []

  description = <<EOF
    (Optional) List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between your etcd nodes and the Kubernetes control plane.
EOF
}

variable "subnet_ids" {
  type = "list"

  description = <<EOF
    (Required) List of subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your etcd nodes and the Kubernetes control plane.
EOF
}

variable "zone_id" {
  type = "string"

  description = <<EOF
    (Required) The ID of a private Route53 hosted zone.
EOF
}

variable "certs_hostnames" {
  type    = "list"
  default = []

  description = <<EOF
    (Optional) This declares the hostnames to be used in the certificates.
EOF
}

variable "certs_ip_addresses" {
  type    = "list"
  default = []

  description = <<EOF
    (Optional) This declares the IP addresses to be used in the certificates.
EOF
}

variable "certs_validity_period_hours" {
  type = "string"

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 26280

  description = <<EOF
    Validity period of the self-signed certificates (in hours). Default is 3 years.
EOF
}

variable "etcd_config" {
  type = "map"

  default = {
    instance_count   = "1"
    ec2_type         = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  description = "(Optional) Desired etcd nodes configuration."
}

variable "ssh_key" {
  type        = "string"
  default     = ""
  description = "The key name that should be used for the instances."
}

variable "s3_bucket" {
  type    = "string"
  default = ""

  description = <<EOF
    (Optional) Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
}

variable "reboot_strategy" {
  type    = "string"
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
}

variable "extra_ignition_file_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition file IDs. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
}

variable "extra_ignition_systemd_unit_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition systemd unit IDs. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
}

variable "extra_tags" {
  type        = "map"
  default     = {}
  description = "Extra AWS tags to be applied to created resources."
}
