variable "kubelet_flag_cloud_provider" {
  type        = "string"
  default     = "aws"
  description = "The provider for cloud services. Specify empty string for running with no cloud provider."
}

variable "kubelet_flag_cloud_config" {
  type        = "string"
  default     = ""
  description = "The path to the cloud provider configuration file.  Empty string for no configuration file."
}

variable "kubelet_flag_cluster_dns" {
  type = "string"

  description = <<EOF
Comma-separated list of DNS server IP address.
This value is used for containers DNS server in case of Pods with "dnsPolicy=ClusterFirst".

Note: all DNS servers appearing in the list MUST serve the same set of records otherwise name resolution
within the cluster may not work correctly. There is no guarantee as to which DNS server may be contacted
for name resolution.
EOF
}

variable "kubelet_flag_cni_bin_dir" {
  type        = "string"
  default     = ""
  description = "The full path of the directory in which to search for CNI plugin binaries."
}

variable "kubelet_flag_node_labels" {
  type        = "string"
  default     = ""
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs separated by ','."
}

variable "kubelet_flag_register_with_taints" {
  type    = "string"
  default = ""

  description = <<EOF
Register the node with the given list of taints (comma separated "<key>=<value>:<effect>").
EOF
}

variable "kubelet_flag_pod_manifest_path" {
  type        = "string"
  default     = "/etc/kubernetes/manifests"
  description = "Path to the directory containing static pod files to run, or the path to a single static pod file. Files starting with dots will be ignored."
}

variable "kubelet_flag_extra_flags" {
  type        = "list"
  default     = []
  description = "Extra user-provided flags to kubelet."
}

variable "hyperkube" {
  type = "map"

  default = {
    image_path = "quay.io/coreos/hyperkube"
    image_tag  = "v1.10.5_coreos.0"
  }

  description = "(Optional) The hyperkube container image path and tag."
}
