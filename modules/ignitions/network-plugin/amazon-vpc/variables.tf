variable "addon_path" {
  description = "Path to the directory containing Kubernetes addons"
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "container_images" {
  description = "Container images to use"
  type        = map(string)
  default = {
    vpc_cni        = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni:v1.6.0"
    calico_node    = "quay.io/calico/node:v3.8.1"
    calico_typha   = "quay.io/calico/typha:v3.8.1"
    k8s_autoscaler = "k8s.gcr.io/cluster-proportional-autoscaler-amd64:1.1.2"
  }
}
