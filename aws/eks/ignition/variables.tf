variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "bootstrap_upgrade_cl" {
  type        = "string"
  description = "(optional) Whether to trigger a ContainerLinux OS upgrade during the bootstrap process."
}

variable "ntp_servers" {
  type        = "list"
  description = "A list of NTP servers to be used for time synchronization on the cluster nodes."
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
}

variable "cloud_provider" {
  type        = "string"
  description = "(optional) The cloud provider to be used for the kubelet."
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type        = "string"
}

variable "client_ca_file" {
  type        = "string"
  description = "The eks cercificate file path."
}

variable "cluster_name" {
  type    = "string"
}

variable "cluster_endpoint" {
  type    = "string"
}

variable "certificate_authority_data" {
  type        = "string"
}

variable "heptio_authenticator_aws_url" {
  type = "string"
}
