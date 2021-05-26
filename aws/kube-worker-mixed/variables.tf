variable "aws_region" {
  type        = "string"
  default     = "us-east-1"
  description = "(Optional) The AWS region"
}

variable "name" {
  type        = "string"
  description = " (Required) Name of the cluster."
}

variable "role_name" {
  type        = "string"
  default     = ""
  description = "(Optional) The Amazon Resource Name of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
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

variable "kubernetes_version" {
  type        = "string"
  default     = "v1.15.12"
  description = "(Optional) Desired Kubernetes kubelet version. If you do not specify a value, the latest available version is used."
}

variable "worker_config" {
  type = "map"

  default = {
    instance_count   = "1"
    ec2_type         = "t2.medium"
    name             = "general"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1
  }

  description = "(Optional) Desired worker nodes configuration."
}

variable "ssh_key" {
  type        = "string"
  default     = ""
  description = "The key name that should be used for the instance."
}

variable "kube_service_cidr" {
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

variable "reboot_strategy" {
  type        = "string"
  default     = "etcd-lock"
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

variable "load_balancer_ids" {
  type        = "list"
  default     = []
  description = "(Optional) A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead."
}

variable "target_group_arns" {
  type        = "list"
  default     = []
  description = "(Optional) A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
}

variable "kubelet_flag_extra_flags" {
  type        = "list"
  default     = []
  description = "Extra user-provided flags to kubelet."
}

variable "extra_tags" {
  type        = "map"
  default     = {}
  description = "Extra AWS tags to be applied to created resources."
}

variable "create_additional_sg" {
  default     = false
  description = "Create a independent security group for workers"
}