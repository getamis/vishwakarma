variable "phase" {
  description = "Specific which phase is used for this eks worker node group"
  type        = "string"
  default     = "dev"
}

variable "project" {
  description = "Specific which project is used for this eks worker node group"
  type        = "string"
  default     = "vishwakarma"
}

variable "ssh_key" {
  description = "The ssh key name for worker node instance"
  type        = "string"
}

variable "aws_region" {
  description = "The AWS region to host this eks worker node group"
  type        = "string"
}

variable "vpc_id" {
  description = "The vpc id to host this eks worker ndoe group"
  type = "string"
}

variable "aws_az_number" {
  description = "How many AZs want to use"
  type    = "string"
  default = "3"
}

variable "container_linux_channel" {
  description = "CoreOS release channel for worker node"
  type        = "string"
  default     = "stable"
}

variable "container_linux_version" {
  description = "CoreOS release version for worker node"
  type        = "string"
  default     = "latest"
}

variable "cluster_name" {
  description = "The eks cluster name"
  type = "string"
}

variable "cluster_endpoint" {
  description = "The eks cluster endpoint"
  type        = "string"
}

variable "certificate_authority_data" {
  description = "The eks cluster certificate authority data"
  type        = "string"
}

variable "worker_name" {
  description = "The name for worker node"
  type        = "string"
}

variable "ec2_type" {
  description = "The ec2 type for worker node"
  type        = "string"
}

variable "ec2_ami" {
  description = "The ami for worker node"
  type        = "string"
  default     = ""
}

variable "instance_count" {
  description = "The minimal worker node number"
  type        = "string"
  default     = "1"
}

variable "subnet_ids" {
  description = "The subnet ids for worker node to host"
  type        = "list"
}

variable "sg_ids" {
  type        = "list"
  description = "The security group IDs to be applied for work node"
}

variable "load_balancers" {
  description = "List of ELBs to attach all worker instances to"
  type        = "list"
  default     = []
}

variable "target_group_arns" {
  description = "List of target groups arn to attach all worker instances to"
  type        = "list"
  default     = []
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "bootstrap_upgrade_cl" {
  type        = "string"
  description = "(optional) Whether to trigger a Container Linux OS upgrade during the bootstrap process"
  default     = "true"
}

variable "ntp_servers" {
  type        = "list"
  description = "A list of NTP servers to be used for time synchronization on the cluster nodes"
  default     = []
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
  default     = ""
}

variable "cloud_provider" {
  type        = "string"
  description = "(optional) The cloud provider to be used for the kubelet"
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
  description = "The eks cercificate file path"
  default     = "/etc/kubernetes/pki/ca.crt"
}

variable "heptio_authenticator_aws_url" {
  description = "heptio authenticator aws download url"
  type        = "string"
  default     = "https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources"
  type        = "map"
  default     = {}
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume for the root block device"
  default     = "gp2"
}

variable "root_volume_size" {
  type        = "string"
  description = "The size of the volume in gigabytes for the root block device"
  default     = "200"
}

variable "root_volume_iops" {
  type        = "string"
  default     = "100"
  description = "The amount of provisioned IOPS for the root block device"
}

variable "worker_iam_role" {
  type        = "string"
  default     = ""
  description = "Exist IAM role to use for the instance profiles of worker nodes"
}

variable "s3_bucket" {
  description = "The s3 bucket to store ignition file for EC2 userdata"
  type        = "string"
}
