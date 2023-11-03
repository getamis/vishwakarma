variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version."
  type        = string
  default     = "v1.27.4"
}

variable "service_cidr" {
  description = "(Optional) The Kubernetes service CIDR."
  type        = string
  default     = "10.96.0.0/12"
}

variable "cluster_cidr" {
  description = "(Optional) The Kubernetes cluster CIDR."
  type        = string
  default     = "10.244.0.0/16"
}

variable "key_pair_name" {
  description = "The ssh key name for all instance, e.g. bastion, master, etcd, worker"
  type        = string
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc', 'cilium-vxlan'"
  type        = string
  default     = "cilium-vxlan"
}

variable "environment" {
  description = "(Optional) environment name, used to compose the resource name"
  type        = string
  default     = "test"
}

variable "project" {
  description = "(Optional) project name, used to compose the resource name"
  type        = string
  default     = "getamis"
}

variable "name" {
  description = "(Optional) name, used to compose the resource name"
  type        = string
  default     = "k8s"
}

variable "service" {
  description = "(Optional) which service provide by this service"
  type        = string
  default     = "kubernetes"
}

variable "endpoint_public_access" {
  description = "(Optional) kubernetes apiserver endpoint"
  default     = false
}

variable "debug_mode" {
  description = "Enable the functionailty for trouble shooting, e.g. sshd"
  type        = bool
  default     = true
}

variable "enable_eni_prefix" {
  description = "(Optional) assign prefix to AWS EC2 network interface"
  type        = bool
  default     = false
}

variable "enable_asg_life_cycle" {
  description = "(Optional) enable ASG life cycle hook or not"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level and verbosity of each components"
  type        = any
  default = {
    aws_cloud_controller_manager = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    aws_vpc_cni                  = "DEBUG" # DEBUG, INFO, WARN, ERROR, FATAL
    containerd                   = "debug" # trace, debug, info, warn, error, fatal, panic
    cilium_cni                   = "None"  # DEBUG: enable debug logging, INFO: disable debug logging
    docker                       = "debug" # debug, info, warn, error, fatal
    etcd                         = "info"  # debug, info, warn, error, panic, fatal
    kube_apiserver               = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_controller_manager      = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_scheduler               = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kube_proxy                   = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    kubelet                      = "4"     # 2: Info, 3: Extended Info, 4: Debug, 5: Trace
    systemd_networkd             = "debug" # emerg, alert, crit, err, warning, notice, info, debug
  }
}