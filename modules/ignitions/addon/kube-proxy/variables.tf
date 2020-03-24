variable "hyperkube" {
  description = "The hyperkube container image path and tag."
  type        = map(string)
}

variable "addon_path" {
  description = "(Optional) The absolute path of the addons to be installed."
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "cluster_cidr" {
  description = "The kubernetes cluster range"
  type        = string
  default     = "10.2.0.0/16"
}
