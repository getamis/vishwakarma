variable "name" {
  description = "(Required) Name of the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version."
  type        = string
  default     = "v1.31.1"
}

variable "override_binaries" {
  description = "Desired binaries(etcd, kubelet, cni_plugin) url and checksum."
  type = map(object({
    source   = string
    checksum = string
  }))
  default = {}
}

variable "override_containers" {
  description = "Desired containers(kube-apiserver, kube-controller-manager, cfssl, coredns, and so on) repo and tag."
  type = map(object({
    repo = string
    tag  = string
  }))
  default = {}
}

variable "override_components_resource" {
  description = "Desired resource requests and limits of kubernetes components(kube-apiserver, kube-controller-manager, kube-scheduler, etc.)"
  type = map(object({
    cpu_request    = string
    cpu_limit      = string
    memory_request = string
    memory_limit   = string
  }))
  default = {}
}
variable "kube_apiserver_secure_port" {
  description = "The port on which to serve HTTPS with authentication and authorization for kube-apiserver."
  type        = number
  default     = 6443
}

variable "kube_service_network_cidr" {
  description = "The kubernetes service ip range"
  type        = string
  default     = "172.16.0.0/13"
}

variable "kube_cluster_network_cidr" {
  description = "The kubernetes cluster ip range"
  type        = string
  default     = "172.24.0.0/13"
}

variable "kube_node_cidr_mask_size" {
  description = "(Optional)[cilium-vxlan] Mask size for node cidr in cluster."
  type        = number
  default     = 24
}

variable "network_plugin" {
  description = "Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc', 'cilium-vxlan'"
  type        = string
  default     = "amazon-vpc"
}

variable "kube_extra_flags" {
  description = <<EOF
The user-provided flags to kubelet, kube-apiserver, kube-controller-manager, kube-scheduler and audit log. 
For flags, we need to follow component flag string format. Do not use underline.
EOF 
  type        = map(map(string))
  default = {
    kubelet            = {}
    apiserver          = {}
    controller_manager = {}
    scheduler          = {}
    audit_log          = {}
  }
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

variable "kube_audit_log_policy_content" {
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
  description = "(Optional) Enable AWS IAM role service account or not"
  type        = bool
  default     = false
}

variable "irsa_oidc_config" {
  description = "The service account config to enable pod identity feature"
  type = object({
    issuer        = string
    api_audiences = string
  })

  default = {
    issuer        = ""
    api_audiences = "sts.amazonaws.com"
  }
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
  description = "The service account keypair content for Kubernetes. If keypair is empty, "
  type = object({
    pub_key = string
    pri_key = string
  })

  default = {
    pub_key = ""
    pri_key = ""
  }
}

variable "reboot_strategy" {
  description = "(Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off"
  type        = string
  default     = "off"
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

// -----------------------------------------
// AWS-related Arguments
// -----------------------------------------

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

variable "enable_eni_prefix" {
  description = "(Optional) assign prefix to AWS EC2 network interface"
  type        = bool
  default     = true
}

variable "enable_asg_life_cycle" {
  description = "(Optional) enable ASG life cycle hook or not"
  type        = bool
  default     = true
}

variable "annotate_pod_ip" {
  description = "(Optional) enable to fix pod startup connectivity issue on installing Calico with aws-vpc-cni plugin. (Issue: https://github.com/aws/amazon-vpc-cni-k8s/issues/493)"
  type        = bool
  default     = false
}

variable "external_snat" {
  description = "(Optional) [AWS VPC CNI] Specifies whether an external NAT gateway should be used to provide SNAT of secondary ENI IP addresses. If set to true, the SNAT iptables rule and off-VPC IP rule are not applied, and these rules are removed if they have already been applied."
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "(Optional) [AWS VPC CNI] Enable AWS Network Policy Agent."
  type        = bool
  default     = false
}

variable "max_pods" {
  description = "(Optional) the max pod number in the node when enable eni prefix"
  type        = string
  default     = "110"
}

variable "master_instance_config" {
  description = "(Optional) Desired master nodes configuration."
  type = object({
    count            = number
    image_id         = string
    ec2_type         = list(string)
    root_volume_iops = number
    root_volume_size = number
    root_volume_type = string

    default_cooldown          = number
    health_check_grace_period = number

    suspended_processes = list(string)

    instance_refresh       = bool
    instance_warmup        = number
    min_healthy_percentage = number

    on_demand_base_capacity                  = number
    on_demand_percentage_above_base_capacity = number
    spot_instance_pools                      = number
    spot_allocation_strategy                 = string
  })
  default = {
    count    = 1
    image_id = "ami-0b75e2f157200889f"
    ec2_type = [
      "t3.medium",
      "t2.medium"
    ]
    root_volume_iops = 100
    root_volume_size = 256
    root_volume_type = "gp2"

    default_cooldown          = 300
    health_check_grace_period = 300

    suspended_processes = []

    instance_refresh       = false
    instance_warmup        = 30
    min_healthy_percentage = 100

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1
    spot_allocation_strategy                 = "lowest-price"
  }
}

variable "master_instance_spot_max_price" {
  type        = string
  default     = ""
  description = "Desired master nodes spot maximum price, default is the on-demand price."
}


variable "etcd_instance_config" {
  description = "(Optional) Desired etcd nodes configuration."
  type = object({
    count              = number
    image_id           = string
    ec2_type           = string
    root_volume_size   = number
    data_volume_size   = number
    data_device_name   = string
    data_device_rename = string
    data_path          = string
  })
  default = {
    count              = 1
    image_id           = "ami-0b75e2f157200889f"
    ec2_type           = "t3.medium"
    root_volume_size   = 40
    data_volume_size   = 100
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/var/lib/etcd"
  }
}

variable "etcd_instance_volume_config" {
  type = object({
    root = object({
      type       = string
      iops       = number
      throughput = number
    })
    data = object({
      type       = string
      iops       = number
      throughput = number
    })
  })
  default = {
    root = {
      type       = "gp2"
      iops       = 0
      throughput = 0
    }
    data = {
      type       = "gp2"
      iops       = 0
      throughput = 0
    }
  }
}

variable "ssh_key" {
  description = "The key name that should be used for the instances."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "(Optional) A list of CIDR networks to allow ssh access to."
  type        = list(string)
  default     = []
}

variable "allowed_etcd_mgmt_cidr" {
  description = "(Option) A list of CIDR networks to allow to manage etcd cluster."
  type        = list(string)
  default     = []
}

variable "hostzone" {
  description = "(Optional) The cluster private hostname. If not specified, <cluster name>.com will be used."
  type        = string
  default     = ""
}

variable "debug_mode" {
  description = "Enable the functionailty for trouble shooting, e.g. sshd"
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "(Optional) Extra AWS tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "log_level" {
  description = "Log level and verbosity of each components"
  type = object({
    aws_cloud_controller_manager = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    aws_vpc_cni                  = optional(string, "DEBUG")   # DEBUG, INFO, WARN, ERROR, FATAL
    containerd                   = optional(string, "info")    # trace, debug, info, warn, error, fatal, panic
    cilium_cni                   = optional(string, "DEBUG")   # DEBUG: enable debug logging, INFO: disable debug logging
    docker                       = optional(string, "info")    # debug, info, warn, error, fatal
    etcd                         = optional(string, "info")    # debug, info, warn, error, panic, fatal
    kube_apiserver               = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_controller_manager      = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_scheduler               = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_proxy                   = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kubelet                      = optional(string, "2")       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    systemd_networkd             = optional(string, "warning") # emerg, alert, crit, err, warning, notice, info, debug
  })
  default = {
    aws_cloud_controller_manager = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    aws_vpc_cni                  = "DEBUG"   # DEBUG, INFO, WARN, ERROR, FATAL
    containerd                   = "info"    # trace, debug, info, warn, error, fatal, panic
    cilium_cni                   = "DEBUG"   # DEBUG: enable debug logging, INFO: disable debug logging
    docker                       = "info"    # debug, info, warn, error, fatal
    etcd                         = "info"    # debug, info, warn, error, panic, fatal
    kube_apiserver               = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_controller_manager      = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_scheduler               = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_proxy                   = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kubelet                      = "2"       # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    systemd_networkd             = "warning" # emerg, alert, crit, err, warning, notice, info, debug
  }
}