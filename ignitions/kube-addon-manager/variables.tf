variable "hyperkube" {
  type = "map"

  default = {
    image_path = "quay.io/coreos/hyperkube"
    image_tag  = "v1.10.5_coreos.0"
  }

  description = "(Optional) The hyperkube container image path and tag."
}

variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "(Optional) The absolute path of the addons to be installed."
}
