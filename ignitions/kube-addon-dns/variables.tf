variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "Path to the directory containing Kubernetes addons"
}

variable "image" {
  type        = "string"
  default     = "coredns/coredns:1.2.6"
  description = "The CoreDNS image name and tag"
}

variable "replicas" {
  default     = 2
  description = "Number of replicas for CoreDNS pod"
}

variable "reverse_cidrs" {
  type        = "string"
  description = "CoreDNS reverse cidrs"
}

variable "cluster_dns_ip" {
  type        = "string"
  description = "K8S cluster dns ip"
}

variable "cluster_domain" {
  type        = "string"
  default     = "cluster.local."
  description = "K8S cluster domain"
}

variable "federations" {
  type        = "string"
  default     = ""
  description = "federations"
}

variable "subdomains" {
  type        = "string"
  default     = ""
  description = "subdomains"
}

variable "upstream_nameserver" {
  type        = "string"
  default     = "/etc/resolv.conf"
  description = "upstream nameserver"
}

variable "located_on_the_same_host" {
  default     = false
  description = "Allow instances of DNS can located on the same master host"
}
