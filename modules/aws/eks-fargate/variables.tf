variable "fargate_profile_name" {
  description = "The fargate profile name"
  type        = string
}

variable "cluster_name" {
  description = "The eks cluster name"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for selection"
  type        = string
}

variable "kubernetes_labels" {
  type        = map(string)
  description = "Key-value mapping of Kubernetes labels for selection"
  default     = {}
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

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
