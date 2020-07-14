variable "container" {
  description = "The container image repo and tag."
  type = object({
    repo = string
    tag  = string
  })
  default = {
    repo = "quay.io/coreos/pod-checkpointer"
    tag  = "e22cc0e3714378de92f45326474874eb602ca0ac"
  }
}

variable "addons_path" {
  description = "(Optional) The absolute path of the addons to be installed."
  type        = string
  default     = "/etc/kubernetes/addons"
}
