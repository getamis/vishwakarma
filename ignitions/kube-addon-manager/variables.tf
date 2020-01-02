variable "hyperkube" {
  type = "map"

  default = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.15.7"
  }

  description = "(Optional) The hyperkube container image path and tag."
}

variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "(Optional) The absolute path of the addons to be installed."
}
