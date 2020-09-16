variable "name" {
  description = " (Required) Name of the cluster."
  type        = string
}

variable "binaries" {
  description = "Desired binaries(cni_plugin) url and checksum."
  type = map(object({
    url      = string
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

variable "network_plugin" {
  description = "Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "amazon-vpc"
}

variable "etcd_endpoints" {
  description = "The etcd endpoints to be accessed by the Kubernetes API server."
  type        = list(string)
}

variable "etcd_certs" {
  description = "The ectd of certs."
  type        = map(string)
}

variable "service_network_cidr" {
  description = "The kubernetes service ip range"
  type        = string
}

variable "cluster_network_cidr" {
  description = "The kubernetes cluster ip range"
  type        = string
}

variable "apiserver_secure_port" {
  description = "The port on which to serve HTTPS with authentication and authorization for kube-apiserver."
  type        = number
  default     = 6443
}

variable "kubelet_extra_config" {
  description = "The user-provided configs to kubelet. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information."
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

variable "extra_flags" {
  description = <<EOF
The user-provided flags to kubelet, kube-apiserver, kube-controller-manager, kube-scheduler and audit log. 
For flags, we need to follow component flag string format. Do not use underline.
EOF 
  default = {
    kubelet            = {}
    apiserver          = {}
    controller_manager = {}
    scheduler          = {}
    audit_log          = {}
  }
}

variable "audit_log_policy_content" {
  description = "The policy content for auditing log."
  type        = string
  default     = <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
}

variable "enable_iam_auth" {
  description = "Enable AWS IAM authenticator or not."
  type        = bool
  default     = false
}

variable "auth_webhook_kubeconfig_path" {
  description = "The path of webhook kubeconfig for kube-apiserver."
  type        = string
  default     = "/etc/kubernetes/config/aws-iam-authenticator/kubeconfig"
}

variable "enable_irsa" {
  description = "Enable AWS IAM role service account or not."
  type        = bool
  default     = false
}

variable "oidc_config" {
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

variable "kube_proxy_config" {
  description = "The configuration of kube-proxy. The variables need to follow https://github.com/kubernetes/kube-proxy/blob/master/config/v1alpha1/types.go. Do not use underline."
  default     = {}
}

variable "coredns_config" {
  description = "The configuration of CoreDNS."
  default     = {}
}

variable "certs_validity_period_hours" {
  description = "Validity period of the self-signed certificates (in hours). Default is 10 years."
  type        = string
  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}

variable "service_account_content" {
  description = "The service account keypair content for Kubernetes."
  type = object({
    pub_key = string
    pri_key = string
  })

  default = {
    pub_key = ""
    pri_key = ""
  }
}

// -----------------------------------------
// AWS-related Variables
// -----------------------------------------

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

variable "instance_config" {
  description = "(Optional) Desired master nodes configuration."
  type        = map(string)
  default = {
    count            = "1"
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

variable "s3_bucket" {
  description = <<EOF
    Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.
EOF
  type        = string
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
