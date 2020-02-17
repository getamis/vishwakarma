variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "container_images" {
  description = "Container images to use"
  type        = map(string)
  default = {
    flannel   = "quay.io/coreos/flannel:v0.11.0-amd64"
    hyperkube = "gcr.io/google-containers/hyperkube-amd64:v1.15.7"
  }
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = string
}

