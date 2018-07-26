variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "Path to the directory containing Kubernetes addons"
}

variable "images" {
  type = "map"

  default = {
    kubedns         = "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5"
    kubednsmasq     = "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5"
    kubedns_sidecar = "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5"
  }
}

variable "cluster_dns_ip" {
  type = "string"

  description = "The DNS service IP address"
}
