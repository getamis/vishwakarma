variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "image" {
  description = "The CoreDNS image name and tag"
  type        = string
  default     = "k8s.gcr.io/coredns:1.6.2"
}

variable "replicas" {
  description = "Number of replicas for CoreDNS pod"
  type        = number
  default     = 2
}

variable "reverse_cidrs" {
  description = "CoreDNS reverse cidrs"
  type        = string
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

variable "federations" {
  description = "federations"
  type        = string
  default     = ""
}

variable "subdomains" {
  description = "subdomains"
  type        = string
  default     = ""
}

variable "upstream_nameserver" {
  description = "upstream nameserver"
  type        = string
  default     = "/etc/resolv.conf"
}

variable "located_on_the_same_host" {
  description = "Allow instances of DNS can located on the same master host"
  type        = bool
  default     = false
}
