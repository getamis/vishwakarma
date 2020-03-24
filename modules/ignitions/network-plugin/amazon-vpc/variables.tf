variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "container_images" {
  description = "Container images to use"
  type        = map(string)
}
