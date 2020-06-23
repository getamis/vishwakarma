// -----------------------------------------
// EKS-like Arguments
// -----------------------------------------

variable "name" {
  description = " (Required) Name of the cluster."
  type        = string
}

variable "enable_auth" {
  description = "(Optional) Enable AWS authenticator or not"
  type        = bool
  default     = false
}

variable "enable_irsa" {
  description = "(Optional) Enable AWS IAM role service account or not"
  type        = bool
  default     = false
}

variable "enable_audit" {
  description = "(Optional) Enable Kubernetes master audit function or not"
  type        = bool
  default     = false
} 

variable "role_name" {
  description = "(Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf."
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
    to use to allow communication to the kubernetes api server load balancer.
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
  default = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.15.12"
  }
}

variable "coredns_container" {
  description = "(Optional) Desired coredns container for K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
  default = {
    image_path = "k8s.gcr.io/coredns"
    image_tag  = "1.6.7"
  }
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "flannel"
}

variable "flannel_containers" {
  description = "(Optional) Desired network plugin flannel container for K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
  default = {
    flannel = "quay.io/coreos/flannel:v0.12.0-amd64"
  }
}

variable "amazon_vpc_containers" {
  description = "(Optional) Desired network plugin amazon vpn container for K8S cluster. If you do not specify a value, the latest available version is used."
  type        = map(string)
  default = {
    vpc_cni        = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni:v1.6.0"
    calico_node    = "quay.io/calico/node:v3.8.1"
    calico_typha   = "quay.io/calico/typha:v3.8.1"
    k8s_autoscaler = "k8s.gcr.io/cluster-proportional-autoscaler-amd64:1.1.2"
  }
}

// -----------------------------------------
// Extra Arguments
// -----------------------------------------
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
    instance_count     = "1"
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"
  }
}

variable "etcd_container" {
  description = "Desired etcd container path and tag"
  type        = map(string)

  default = {
    image_path = "quay.io/coreos/etcd"
    image_tag  = "v3.4.5"
  }
}

variable "ssh_key" {
  description = "The key name that should be used for the instances."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "(Optional) A list of CIDR networks to allow ssh access to. Defaults to \"0.0.0.0/0\""
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_cidr" {
  description = "(Optional) The Kubernetes service CIDR."
  type        = string
  default     = "172.16.0.0/13"
}

variable "cluster_cidr" {
  description = "(Optional) The Kubernetes cluster CIDR."
  type        = string
  default     = "172.24.0.0/13"
}

variable "hostzone" {
  description = "(Optional) The cluster private hostname. If not specified, <cluster name>.com will be used."
  type        = string
  default     = ""
}

variable "reboot_strategy" {
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
  type        = string
  default     = "off"
}

variable "extra_master_node_labels" {
  description = "(Optional) Labels to add when registering the node in the cluster. Labels must be key=value pairs."
  type        = list(string)
  default     = []
}

variable "extra_master_node_taints" {
  description = <<EOF
(Optional) Register the node with the given list of taints ("<key>=<value>:<effect>").
EOF
  type        = list(string)
  default     = []
}

variable "extra_etcd_ignition_file_ids" {
  description = "(Optional) Additional ignition file IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_etcd_ignition_systemd_unit_ids" {
  description = "(Optional) Additional ignition systemd unit IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_ignition_file_ids" {
  description = "(Optional) Additional ignition file IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details."
  type        = list(string)
  default     = []
}

variable "extra_ignition_systemd_unit_ids" {
  description = "(Optional) Additional ignition systemd unit IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details."
  type        = list(string)
  default     = []
}

variable "kubelet_flag_extra_flags" {
  description = "Extra user-provided flags to kubelet."
  type        = list(string)
  default     = []
}

variable "extra_tags" {
  description = "(Optional) Extra AWS tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "audit_policy_path" {
  description = "(Optional) A policy path for Kubernetes apiserver to enable auditing log."
  type        = string
  default     = "/etc/kubernetes/audit"
}

variable "audit_log_backend" {
  description = <<EOF
    (Optional) Kubernetes apiserver auditing log backend configuration,
    there are four parameters: path, maxage, maxbackup, maxsize.
EOF
  type        = map(string)
  default = {
    path      = "/var/log/kubernetes/kube-apiserver.log"
    maxage    = "30"
    maxbackup = "30"
    maxsize   = "10"
  }
}

variable "audit_policy" {
  description = "The policy for auditing log."
  type        = string
  default     = <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
}

variable "oidc_api_audiences" {
  description = "the OIDC authenticator pre-introduction of API audiences"
  type        = string
  default     = "sts.amazonaws.com"
}