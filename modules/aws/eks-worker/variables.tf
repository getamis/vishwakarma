variable "aws_az_number" {
  description = "How many AZs want to use"
  type        = string
  default     = "3"
}

variable "cluster_name" {
  description = "the eks cluster name"
  type        = string
}

variable "enable_autoscaler" {
  description = "enable autoscaler or not"
  type        = bool
  default     = false
}

variable "kube_node_labels" {
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs."
  type        = list(string)
  default     = []
}

variable "kube_node_taints" {
  description = <<EOF
Register the node with the given list of taints ("<key>=<value>:<effect>").
EOF
  type        = list(string)
  default     = []
}

variable "kubernetes_version" {
  type        = string
  default     = "1.14"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "load_balancer_ids" {
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = <<EOF
    List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between your worker nodes and the Kubernetes control plane.
EOF
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = <<EOF
    List of subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your worker nodes and the Kubernetes control plane.
EOF

  type        = list(string)
  default     = []
}

variable "ssh_key" {
  description = "The key name that should be used for the instance."
  type        = string
  default     = ""
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
  type        = list(string)
  default     = []
}

variable "extra_worker_policy_arns" {
  description = "The extra policy need to be attached to worker"
  type        = list(string)
  default     = []
}

variable "worker_config" {
  description = "Desired worker nodes configuration."
  type        = map(string)

  default     = {
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
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}