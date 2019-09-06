variable "kubelet_flag_cloud_provider" {
  description = "The provider for cloud services. Specify empty string for running with no cloud provider."
  type        = string
  default     = "aws"
}

variable "kubelet_flag_cloud_config" {
  description = "The path to the cloud provider configuration file.  Empty string for no configuration file."
  type        = string
  default     = ""
}

variable "kubelet_flag_cluster_dns" {
  description = <<EOF
Comma-separated list of DNS server IP address.
This value is used for containers DNS server in case of Pods with "dnsPolicy=ClusterFirst".

Note: all DNS servers appearing in the list MUST serve the same set of records otherwise name resolution
within the cluster may not work correctly. There is no guarantee as to which DNS server may be contacted
for name resolution.
EOF
  type        = string
}

variable "kubelet_flag_cni_bin_dir" {
  description = "The full path of the directory in which to search for CNI plugin binaries."
  type        = string
  default     = ""
}

variable "kubelet_flag_node_labels" {
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs separated by ','."
  type        = string
  default     = ""
}

variable "kubelet_flag_register_with_taints" {
  description = <<EOF
Register the node with the given list of taints (comma separated "<key>=<value>:<effect>").
EOF
  type    = string
  default = ""
}

variable "kubelet_flag_pod_manifest_path" {
  description = "Path to the directory containing static pod files to run, or the path to a single static pod file. Files starting with dots will be ignored."
  type        = string
  default     = "/etc/kubernetes/manifests"
}

variable "kubelet_flag_extra_flags" {
  description = "Extra user-provided flags to kubelet."
  type        = list(string)
  default     = []
}

variable "hyperkube" {

  description = "(Optional) The hyperkube container image path and tag."
  type        = map(string)
  default     = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.14.6"
  }
}
