variable "bastion_key_name" {
  description = "The key pair name for access bastion & worker node ec2"
  type        = "string"
}

variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = "us-east-1"
}

variable "config_output_path" {
  description = "The path to store config, e.g. kubeconfig"
  type        = "string"
  default     = ".terraform"
}

variable "container_images" {
  description = "(internal) Container images to use"
  type        = "map"

  default = {
    awscli      = "quay.io/amis/awscli:1.15.40"
    hyperkube   = "quay.io/coreos/hyperkube:v1.10.3_coreos.0"
    pause_amd64 = "602401143452.dkr.ecr.REGION.amazonaws.com/eks/pause-amd64:3.1"
  }
}

variable "worker_spot_label" {
  description = "The label name for spot worker"
  type        = "string"
  default     = "node-role.kubernetes.io/node,node-type.kubernetes.io/spot"
}

variable "cloud_provider" {
  type        = "string"
  description = "(optional) The cloud provider to be used for the kubelet."
  default     = "aws"
}

variable "worker_asg" {
  type = "map"
  default = {
    name             = "general"
    ec2_type         = "t2.medium"
    instance_count   = "1"
    root_volume_size = "40"
    root_volume_type = "gp2"
    release_channel  = "stable"
    release_version  = "latest"
    k8s_labels       = "node-role.kubernetes.io/node,node-type.kubernetes.io/general"
  }
}

variable "worker_spot" {
  type = "map"
  default = {
    name             = "spot"
    instance_count   = "1"
    root_volume_size = "40"
    root_volume_type = "gp2"
    release_channel  = "stable"
    release_version  = "latest"
    k8s_labels       = "node-role.kubernetes.io/node,node-type.kubernetes.io/spot"
  }
}


variable "spot_ec2_type" {
  type = "map"
  default = {
    m4.large = "0.05"
    m5.large = "0.05"
  }
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
