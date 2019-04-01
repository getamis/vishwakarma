variable "aws_region" {
  type        = "string"
  default     = "us-west-2"
  description = "(Optional) The AWS region"
}

variable "aws_az_number" {
  description = "How many AZs want to use"
  type    = "string"
  default = "3"
}

variable "aws_iam_authenticator_url" {
  type = "string"
  default = "https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator"
}

variable "cluster_name" {
  type    = "string"
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
variable "kubernetes_version" {
  type        = "string"
  default     = "1.12.7"
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
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

variable "kubelet_flag_extra_flags" {
  type        = "list"
  default     = []
  description = "Extra user-provided flags to kubelet."
}

variable "load_balancer_ids" {
  type        = "list"
  default     = []
  description = "(Optional) A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead."
}

variable "ntp_servers" {
  type        = "list"
  default     = []
  description = "A list of NTP servers to be used for time synchronization on the cluster nodes."
}

variable "reboot_strategy" {
  type    = "string"
  default = "etcd-lock"
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
}

variable "s3_bucket" {
  description = "The s3 bucket to store ignition file for EC2 userdata"
  type        = "string"
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

variable "ssh_key" {
  type        = "string"
  default     = ""
  description = "The key name that should be used for the instance."
}

variable "target_group_arns" {
  type        = "list"
  default     = []
  description = "(Optional) A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
}

variable "extra_worker_policy_arns" {
  type        = "list"
  default     = []
  description = "The extra policy need to be attached to worker"
}

variable "worker_config" {
  type = "map"

  default = {
    instance_count   = "1"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
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

variable "extra_tags" {
  type        = "map"
  default     = {}
  description = "Extra AWS tags to be applied to created resources."
}