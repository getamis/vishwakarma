variable "container" {
  description = "Desired container repo and tag."
  type        = map(string)
  default = {
    repo = "k8s.gcr.io/metrics-server/metrics-server"
    tag  = "v0.3.7"
  }
}

variable "secure_port" {
  description = "The service secure port number."
  type        = number
  default     = 4443
}

variable "addons_dir_path" {
  description = "A path for installing addons."
  type        = string
  default     = "/etc/kubernetes/addons"
}

