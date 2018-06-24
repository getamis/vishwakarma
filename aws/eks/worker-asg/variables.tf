variable "phase" {
  description = "Specific which phase service will host"
  type        = "string"
  default     = "dev"
}

variable "project" {
  description = "Specific which project service will host"
  type        = "string"
  default     = "vishwakarma"
}

variable "ssh_key" {
  type = "string"
}

variable "aws_region" {
  description = "The AWS region to build network infrastructure"
  type        = "string"
  default     = ""
}

variable "vpc_id" {
  type = "string"
}

variable "aws_az_number" {
  description = "How many AZs want to build"
  type    = "string"
  default = "3"
}

variable "container_linux_channel" {
  type    = "string"
}

variable "container_linux_version" {
  type    = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "cluster_endpoint" {
  type    = "string"
}

variable "certificate_authority_data" {
  type        = "string"
}

variable "worker_name" {
  type    = "string"
}

variable "ec2_type" {
  type = "string"
}

variable "ec2_ami" {
  type    = "string"
  default = ""
}

variable "instance_count" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied."
  default     = []
}

variable "load_balancers" {
  description = "List of ELBs to attach all worker instances to."
  type        = "list"
  default     = []
}

variable "target_group_arns" {
  description = "List of target groups arn to attach all worker instances to."
  type        = "list"
  default     = []
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "bootstrap_upgrade_cl" {
  type        = "string"
  description = "(optional) Whether to trigger a ContainerLinux OS upgrade during the bootstrap process."
  default     = "true"
}

variable "ntp_servers" {
  type        = "list"
  description = "A list of NTP servers to be used for time synchronization on the cluster nodes."
  default     = []
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
  default     = "aws"
  default     = "/^([^/]+/[^/]+/[^/]+):(.*)$/"
}

variable "cloud_provider" {
  type        = "string"
  description = "(optional) The cloud provider to be used for the kubelet."
  default     = "aws"
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type        = "string"
  default = "/^([^/]+/[^/]+/[^/]+):(.*)$/"
}

variable "client_ca_file" {
  type        = "string"
  description = "The eks cercificate file path."
  default     = "/etc/kubernetes/pki/ca.crt"
}

variable "heptio_authenticator_aws_url" {
  type    = "string"
  default = "https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume for the root block device."
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device."
}

variable "root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device."
}

variable "worker_iam_role" {
  type        = "string"
  default     = ""
  description = "IAM role to use for the instance profiles of worker nodes."
}

variable "s3_bucket" {
  type = "string"
}
