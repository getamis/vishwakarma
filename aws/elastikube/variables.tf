// -----------------------------------------
// EKS-like Arguments
// -----------------------------------------

variable "name" {
  type        = "string"
  description = " (Required) Name of the cluster."
}

variable "role_arn" {
  type        = "string"
  default     = ""
  description = "(Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
}

variable "security_group_ids" {
  type    = "list"
  default = []

  description = <<EOF
    (Optional) List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between your worker nodes and the Kubernetes control plane.
EOF
}

variable "subnet_ids" {
  type    = "list"
  default = []

  description = <<EOF
    (Required) List of subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your worker nodes and the Kubernetes control plane.
EOF
}

variable "version" {
  type        = "string"
  default     = "v1.10.5"
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

// -----------------------------------------
// Extra Arguments
// -----------------------------------------

variable "aws_region" {
  type        = "string"
  default     = "us-east-1"
  description = "(Optional) The AWS region"
}

variable "master_config" {
  type = "map"

  default = {
    instance_count   = "1"
    ec2_type         = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  description = "(Optional) Desired master nodes configuration."
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

variable "service_cidr" {
  type        = "string"
  default     = "172.16.0.0/13"
  description = "(Optional) The Kubernetes service CIDR."
}

variable "cluster_cidr" {
  type        = "string"
  default     = "172.24.0.0/13"
  description = "(Optional) The Kubernetes cluster CIDR."
}

variable "hostzone" {
  type        = "string"
  default     = ""
  description = "(Optional) The cluster private hostname. If not specified, <cluster name>.com will be used."
}

variable "extra_master_node_labels" {
  type        = "list"
  default     = []
  description = "(Optional) Labels to add when registering the node in the cluster. Labels must be key=value pairs."
}

variable "extra_master_node_taints" {
  type    = "list"
  default = []

  description = <<EOF
(Optional) Register the node with the given list of taints ("<key>=<value>:<effect>").
EOF
}

variable "extra_etcd_ignition_file_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition file IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
}

variable "extra_etcd_ignition_systemd_unit_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition systemd unit IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
}

variable "extra_ignition_file_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition file IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
}

variable "extra_ignition_systemd_unit_ids" {
  type        = "list"
  default     = []
  description = "(Optional) Additional ignition systemd unit IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
}

variable "extra_tags" {
  description = "(Optional) Extra AWS tags to be applied to the resources."
  type        = "map"
  default     = {}
}
