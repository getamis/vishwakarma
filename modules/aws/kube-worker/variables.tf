variable "name" {
  description = " (Required) Name of the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version."
  type        = string
  default     = "v1.19.10"
}

variable "binaries" {
  description = "Desired binaries(cni_plugin) url and checksum."
  type = map(object({
    source   = string
    checksum = string
  }))
  default = {}
}

variable "containers" {
  description = "Desired containers(kube-apiserver, kube-controller-manager, cfssl, coredns, and so on) repo and tag."
  type = map(object({
    repo = string
    tag  = string
  }))
  default = {}
}

variable "service_network_cidr" {
  description = "The kubernetes service ip range"
  type        = string
}

variable "network_plugin" {
  description = "Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "amazon-vpc"
}

variable "cloud_config" {
  description = "The cloud provider configuration."
  type = object({
    provider = string
    path     = string
  })
  default = {
    provider = ""
    path     = ""
  }
}

variable "kubelet_config" {
  description = "The configuration of kubelet. The variables need to follow https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubelet/config/v1beta1/types.go. Do not use underline."
  default     = {}
}

variable "kubelet_flags" {
  description = "The flags of kubelet. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/. Do not use underline."
  type        = map(string)
  default     = {}
}

variable "kubelet_node_labels" {
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs."
  type        = list(string)
  default     = []
}

variable "kubelet_node_taints" {
  description = "Register the node with the given list of taints (\"<key>=<value>:<effect>\")."
  type        = list(string)
  default     = []
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

// -----------------------------------------
// AWS-related Variables
// -----------------------------------------

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

variable "instance_config" {
  description = "Desired worker nodes configuration."
  type = object({
    count            = number
    name             = string
    image_id         = string
    ec2_type         = list(string)
    root_volume_iops = number
    root_volume_size = number
    root_volume_type = string

    instance_warmup        = number
    min_healthy_percentage = number

    on_demand_base_capacity                  = number
    on_demand_percentage_above_base_capacity = number
    spot_instance_pools                      = number
  })
}

variable "enable_autoscaler" {
  description = "Enable to add autoscaler tag or not"
  type        = string
  default     = "false"
}

variable "ssh_key" {
  description = "The key name that should be used for the instance."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = <<EOF
    Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
    If name is not provided the installer will construct the name using "name" and current AWS region.
EOF
  type        = string
  default     = ""
}

variable "s3_object" {
  type    = string
  default = "admin.conf"
}
variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
