variable "name" {
  description = " (Required) Name of the etcd cluster."
  type        = string
}

variable "master_security_group_id" {
  description = <<EOF
    (Required) Main security group ID to use to allow communication between your etcd nodes
    and the Kubernetes control plane.
EOF
  type        = string
}

variable "security_group_ids" {
  description = <<EOF
    (Optional) List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between your etcd nodes and the Kubernetes control plane.
EOF
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = <<EOF
    (Required) List of subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your etcd nodes and the Kubernetes control plane.
EOF
  type        = list(string)
}

variable "zone_id" {
  description = <<EOF
    (Required) The ID of a private Route53 hosted zone.
EOF
  type        = string
}

variable "certs_hostnames" {
  description = <<EOF
    (Optional) This declares the hostnames to be used in the certificates.
EOF
  type        = list(string)
  default     = []
}

variable "certs_ip_addresses" {
  description = <<EOF
    (Optional) This declares the IP addresses to be used in the certificates.
EOF
  type        = list(string)
  default     = []
}

variable "certs_validity_period_hours" {
  description = <<EOF
    Validity period of the self-signed certificates (in hours). Default is 3 years.
EOF
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 26280
}

variable "etcd_config" {
  description = "(Optional) Desired etcd nodes configuration."
  type        = map(string)
  default = {
    instance_count   = "1"
    ec2_type         = "t3.medium"
    root_volume_iops = "100"
    root_volume_size = "100"
    root_volume_type = "gp2"
  }
}

variable "etcd_container" {
  description = "Desired etcd container path and tag"
  type        = map(string)
}

variable "ssh_key" {
  description = "The key name that should be used for the instances."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = <<EOF
    (Optional) Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
  type        = string
  default     = ""
}

variable "reboot_strategy" {
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
  type        = string
}

variable "extra_ignition_file_ids" {
  description = "(Optional) Additional ignition file IDs. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_ignition_systemd_unit_ids" {
  description = "(Optional) Additional ignition systemd unit IDs. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
