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