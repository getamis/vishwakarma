variable "aws_region" {
  type        = "string"
  default     = "us-east-1"
  description = "(Optional) The AWS region"
}

variable "name" {
  type        = "string"
  description = " (Required) Name of the cluster."
}

variable "role_arn" {
  type        = "string"
  default     = ""
  description = "(Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
}

variable "master_security_group_id" {
  type    = "string"
  default = ""

  description = <<EOF
    (Optional) Main security group ID of the Kubernetes control plane.
EOF
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

variable "ssh_key" {
  type        = "string"
  default     = ""
  description = "The key name that should be used for the instance."
}

variable "etcd_endpoints" {
  type = "list"

  description = <<EOF
  (Required) The etcd endpoints to be accessed by the Kubernetes API server.
  EOF
}

variable "etcd_certs_config" {
  type = "map"
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

variable "kube_service_cidr" {
  type        = "string"
  description = ""
}

variable "kube_cluster_cidr" {
  type        = "string"
  description = ""
}

variable "kube_node_labels" {
  type        = "list"
  default     = []
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs."
}

variable "kube_node_taints" {
  type    = "list"
  default = []

  description = <<EOF
Register the node with the given list of taints ("<key>=<value>:<effect>").
EOF
}

variable "s3_bucket" {
  type    = "string"
  default = ""

  description = <<EOF
    (Optional) Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
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
