variable "container" {
  description = "Desired container repo and tag."
  type        = map(string)
  default = {
    repo = "k8s.gcr.io/kube-addon-manager"
    tag  = "v8.7"
  }
}

variable "kubectl_extra_prune_whitelist" {
  description = "A list of extra whitelisted resources"
  type        = list(string)
  default     = []
}

variable "manifests_dir_path" {
  description = "A path for executing Kubernetes resources by kubelet."
  type        = string
  default     = "/etc/kubernetes/manifests"
}

variable "addons_dir_path" {
  description = "A path for installing addons."
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "logs_dir_path" {
  description = "A path for recording logs."
  type        = string
  default     = "/var/log/kubernetes"
}