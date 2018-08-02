variable "manifest_path" {
  type        = "string"
  default     = "/etc/kubernetes/manifests"
  description = "Path to the directory containing static manifests"
}

variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "Path to the directory containing Kubernetes addons"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"

  default = {
    flannel_cni = "quay.io/coreos/flannel-cni:v0.2.0"
    flannel     = "quay.io/coreos/flannel:v0.8.0-amd64"
  }
}

variable "kube_apiserver_config" {
  type = "map"

  default = {
    host = "https://localhost"
    port = 443
  }

  description = "(Required) The API server endpoint and port."
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}
