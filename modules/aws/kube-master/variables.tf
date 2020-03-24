variable "name" {
  description = " (Required) Name of the cluster."
  type        = string
}

variable "role_name" {
  description = "(Optional) The Amazon Resource Name of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
  type        = string
  default     = ""
}

variable "master_security_group_id" {
  description = <<EOF
    (Optional) Main security group ID of the Kubernetes control plane.
EOF
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = <<EOF
    (Optional) List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between your worker nodes and the Kubernetes control plane.
EOF
  type        = list(string)
  default     = []


}

variable "lb_security_group_ids" {
  description = <<EOF
    (Optional) List of security group IDs for the cross-account elastic network interfaces
    to use to allow communication between you and the kubernetes api server load balancer.
EOF
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = <<EOF
    (Required) List of public subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your worker nodes and the Kubernetes control plane.
EOF
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = <<EOF
    (Required) List of private subnet IDs. Must be in at least two different availability zones.
    Cross-account elastic network interfaces will be created in these subnets to allow
    communication between your worker nodes and the Kubernetes control plane.
EOF
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "(Optional) kubernetes apiserver endpoint"
  type        = bool
  default     = false
}

variable "hyperkube_container" {
  description = "(Optional) Desired Hyperkube container to boot K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "flannel"
}

variable "master_config" {
  description = "(Optional) Desired master nodes configuration."
  type        = map(string)
  default = {
    instance_count   = "1"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
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

variable "etcd_endpoints" {
  description = <<EOF
  (Required) The etcd endpoints to be accessed by the Kubernetes API server.
  EOF
  type        = list(string)
}

variable "etcd_certs_config" {
  type = map(string)
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

variable "kube_service_cidr" {
  description = "The kubernetes service ip range"
  type        = string
}

variable "kube_cluster_cidr" {
  description = "The kubernetes cluster ip range"
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

variable "auth_webhook_path" {
  description = "(Optional) A path for using customized machine to authenticate to a Kubernetes cluster."
  type        = string
  default     = ""
}

variable "audit_policy_path" {
  description = "(Optional) A policy path for Kubernetes apiserver to enable auditing log."
  type        = string
  default     = ""
}

variable "audit_log_backend" {
  description = <<EOF
    (Optional) Kubernetes apiserver auditing log backend configuration,
    there are four parameters: path, maxage, maxbackup, maxsize.
EOF
  type        = map(string)
  default     = {}

}

variable "oidc_issuer_confg" {
  description = "The service account config to enable pod identity feature"
  type = object({
    issuer        = string
    api_audiences = string
  })
  default = {
    issuer        = ""
    api_audiences = ""
  }
}
