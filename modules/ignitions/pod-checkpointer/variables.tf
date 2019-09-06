variable "pod_checkpointer" {
  description = "The hyperkube container image path and tag"
  type = map(string)
  default = {
    image_path = "quay.io/coreos/pod-checkpointer"
    image_tag  = "e22cc0e3714378de92f45326474874eb602ca0ac"
  }
}

variable "addon_path" {
  description = "(Optional) The absolute path of the addons to be installed."
  type        = string
  default     = "/etc/kubernetes/addons"
}
