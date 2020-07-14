variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "enable_autoscaler" {
  description = "Enable to add autoscaler tag or not"
  type        = string
  default     = "false"
}

variable "role_name" {
  description = "The Amazon Resource Name of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
  type        = string
  default     = ""
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

variable "hyperkube_container" {
  description = "(Optional) Desired Hyperkube container to boot K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
  default = {
    image_repo = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.15.12"
  }
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "flannel"
}

variable "worker_config" {
  description = "Desired worker nodes configuration."
  type        = map(string)
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
}

variable "ssh_key" {
  description = "The key name that should be used for the instance."
  type        = string
  default     = ""
}

variable "kube_service_cidr" {
  description = "The kubernetes service ip range"
  type        = string
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

variable "s3_bucket" {
  description = <<EOF
    Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
  type        = string
  default     = ""
}

variable "reboot_strategy" {
  description = "CoreOS reboot strategies on updates, two option here: etcd-lock or off"
  type        = string
  default     = "etcd-lock"
}

variable "extra_ignition_file_ids" {
  description = "Additional ignition file IDs. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_ignition_systemd_unit_ids" {
  description = "Additional ignition systemd unit IDs. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
  type        = list(string)
  default     = []
}

variable "load_balancer_ids" {
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead."
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
  type        = list(string)
  default     = []
}

variable "kubelet_flag_extra_flags" {
  description = "Extra user-provided flags to kubelet."
  type        = list(string)
  default     = []
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
