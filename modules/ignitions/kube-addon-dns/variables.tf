variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "image" {
  description = "The CoreDNS image name and tag"
  type        = "string"
  default     = "k8s.gcr.io/coredns:1.6.2"
}

variable "cluster_dns_ip" {
  description = "K8S cluster dns ip"
  type        = string
}

variable "cluster_domain" {
  description = "K8S cluster domain"
  type        = string
  default     = "cluster.local."
}