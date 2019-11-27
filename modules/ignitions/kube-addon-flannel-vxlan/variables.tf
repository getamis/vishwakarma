variable "manifest_path" {
  description = "Path to the directory containing static manifests"
  type        = string
  default     = "/etc/kubernetes/manifests"
}

variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "container_images" {
  description = "Container images to use"
  type        = map(string)
  default     = {
    flannel     = "quay.io/coreos/flannel:v0.11.0-amd64"
  }
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = string
}
