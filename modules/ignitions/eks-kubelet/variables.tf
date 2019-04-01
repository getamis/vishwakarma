variable "aws_region" {
  type = "string"
  default = "us-west-2"
}

variable "kubelet_flag_cni_bin_dir" {
  type        = "string"
  default     = ""
  description = "The full path of the directory in which to search for CNI plugin binaries."
}

variable "kubelet_flag_config" {
  type        = "string"
  default     = "/var/lib/kubelet/kubelet.json"
  description = "The kubelet config path"
}

variable "kubelet_flag_container_runtime" {
  type = "string"
  default = "docker"
  description = "the container runtime which is used by"
}

variable "kubelet_flag_kubeconfig" {
  type        = "string"
  default     = "/var/lib/kubelet/kubeconfig"
  description = "The kubeconfig path"
}

variable "kubelet_flag_max_pods" {
  type        = "string"
  default     = ""
  description = "The max pods in the worker"
}

variable "kubelet_flag_node_labels" {
  type        = "string"
  default     = ""
  description = "Labels to add when registering the node in the cluster. Labels must be key=value pairs separated by ','."
}

variable "kubelet_flag_pod_infra_container_image" {
  type = "string"
  default = "602401143452.dkr.ecr.REGION.amazonaws.com/eks/pause-amd64:3.1"
  description = "EKS infra container"
}
variable "kubelet_flag_pod_manifest_path" {
  type        = "string"
  default     = "/etc/kubernetes/manifests"
  description = "Path to the directory containing static pod files to run, or the path to a single static pod file. Files starting with dots will be ignored."
}

variable "kubelet_flag_register_with_taints" {
  type    = "string"
  default = ""

  description = <<EOF
Register the node with the given list of taints (comma separated "<key>=<value>:<effect>").
EOF
}

variable "kubelet_flag_extra_flags" {
  type        = "list"
  default     = []
  description = "Extra user-provided flags to kubelet."
}

variable "hyperkube_image_path" {
  type        = "string"
  default     = "gcr.io/google-containers/hyperkube-amd64"
  description = "(Optional) The hyperkube container image path."
}

variable "hyperkube_image_tag" {
  type        = "string"
  default     = "v1.12.7"
  description = "(Optional) The hyperkube container image tag."
}

variable "client_ca_file_path" {
  type        = "string"
  default     = "/etc/kubernetes/pki/ca.crt"
  description = "The eks cercificate in worker file path."
}

variable "certificate_authority_data" {
  type = "string"
  description = "EKS certificate authority data"
}

variable "instance_type" {
  type = "string"
  description = "The EC2 instance type which is used by the worker"
}

variable "eni_max_pods" {
  type = "map"
  description = <<EOF
    (Optional) Mapping is calculated from AWS ENI documentation, with the following modifications:
    * First IP on each ENI is not used for pods
    * 2 additional host-networking pods (AWS ENI and kube-proxy) are accounted for

     of ENI * (# of IPv4 per ENI - 1)  + 2

     https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI

     If f1.16xlarge, g3.16xlarge, h1.16xlarge, i3.16xlarge, and r4.16xlarge instances use more than 31 IPv4 or IPv6 addresses per interface, they cannot access the instance metadata, VPC DNS, and Time Sync services from the 32nd IP address onwards. If access to these services is needed from all IP addresses on the interface, we recommend using a maximum of 31 IP addresses per interface. 

     commit id: fb0c393861ce045bb4f2ffebbd8bf23b1240bc99 (amazon-eks-ami)
EOF

  default = {
    c1.medium     = 12
    c1.xlarge     = 58
    c3.large      = 29
    c3.xlarge     = 58
    c3.2xlarge    = 58
    c3.4xlarge    = 234
    c3.8xlarge    = 234
    c4.large      = 29
    c4.xlarge     = 58
    c4.2xlarge    = 58
    c4.4xlarge    = 234
    c4.8xlarge    = 234
    c5.large      = 29
    c5.xlarge     = 58
    c5.2xlarge    = 58
    c5.4xlarge    = 234
    c5.9xlarge    = 234
    c5.18xlarge   = 737
    c5d.large     = 29
    c5d.xlarge    = 58
    c5d.2xlarge   = 58
    c5d.4xlarge   = 234
    c5d.9xlarge   = 234
    c5d.18xlarge  = 737
    cc2.8xlarge   = 234
    cr1.8xlarge   = 234
    d2.xlarge     = 58
    d2.2xlarge    = 58
    d2.4xlarge    = 234
    d2.8xlarge    = 234
    f1.2xlarge    = 58
    f1.4xlarge    = 234
    f1.16xlarge   = 242
    g2.2xlarge    = 58
    g2.8xlarge    = 234
    g3s.xlarge    = 58
    g3.4xlarge    = 234
    g3.8xlarge    = 234
    g3.16xlarge   = 452
    h1.2xlarge    = 58
    h1.4xlarge    = 234
    h1.8xlarge    = 234
    h1.16xlarge   = 452
    hs1.8xlarge   = 234
    i2.xlarge     = 58
    i2.2xlarge    = 58
    i2.4xlarge    = 234
    i2.8xlarge    = 234
    i3.large      = 29
    i3.xlarge     = 58
    i3.2xlarge    = 58
    i3.4xlarge    = 234
    i3.8xlarge    = 234
    i3.16xlarge   = 452
    i3.metal      = 737
    m1.small      = 8
    m1.medium     = 12
    m1.large      = 29
    m1.xlarge     = 58
    m2.xlarge     = 58
    m2.2xlarge    = 118
    m2.4xlarge    = 234
    m3.medium     = 12
    m3.large      = 29
    m3.xlarge     = 58
    m3.2xlarge    = 118
    m4.large      = 20
    m4.xlarge     = 58
    m4.2xlarge    = 58
    m4.4xlarge    = 234
    m4.10xlarge   = 234
    m4.16xlarge   = 234
    m5.large      = 29
    m5.xlarge     = 58
    m5.2xlarge    = 58
    m5.4xlarge    = 234
    m5.12xlarge   = 234
    m5.24xlarge   = 737
    m5a.large     = 29
    m5a.xlarge    = 58
    m5a.2xlarge   = 58
    m5a.4xlarge   = 234
    m5a.12xlarge  = 234
    m5a.24xlarge  = 737
    m5d.large     = 29
    m5d.xlarge    = 58
    m5d.2xlarge   = 58
    m5d.4xlarge   = 234
    m5d.12xlarge  = 234
    m5d.24xlarge  = 737
    p2.xlarge     = 58
    p2.8xlarge    = 234
    p2.16xlarge   = 234
    p3.2xlarge    = 58
    p3.8xlarge    = 234
    p3.16xlarge   = 234
    p3dn.24xlarge = 737
    r3.large      = 29
    r3.xlarge     = 58
    r3.2xlarge    = 58
    r3.4xlarge    = 234
    r3.8xlarge    = 234
    r4.large      = 29
    r4.xlarge     = 58
    r4.2xlarge    = 58
    r4.4xlarge    = 234
    r4.8xlarge    = 234
    r4.16xlarge   = 452
    r5.large      = 29
    r5.xlarge     = 58
    r5.2xlarge    = 58
    r5.4xlarge    = 234
    r5.12xlarge   = 234
    r5.24xlarge   = 737
    r5a.large     = 29
    r5a.xlarge    = 58
    r5a.2xlarge   = 58
    r5a.4xlarge   = 234
    r5a.12xlarge  = 234
    r5a.24xlarge  = 737
    r5d.large     = 29
    r5d.xlarge    = 58
    r5d.2xlarge   = 58
    r5d.4xlarge   = 234
    r5d.12xlarge  = 234
    r5d.24xlarge  = 737
    t1.micro      = 4
    t2.nano       = 4
    t2.micro      = 4
    t2.small      = 11
    t2.medium     = 17
    t2.large      = 35
    t2.xlarge     = 44
    t2.2xlarge    = 44
    t3.nano       = 4
    t3.micro      = 4
    t3.small      = 11
    t3.medium     = 17
    t3.large      = 35
    t3.xlarge     = 58
    t3.2xlarge    = 58
    x1.16xlarge   = 234
    x1.32xlarge   = 234
    x1e.xlarge    = 29
    x1e.2xlarge   = 58
    x1e.4xlarge   = 58
    x1e.8xlarge   = 58
    x1e.16xlarge  = 234
    x1e.32xlarge  = 234
    z1d.large     = 29
    z1d.xlarge    = 58
    z1d.2xlarge   = 58
    z1d.3xlarge   = 234
    z1d.6xlarge   = 234
    z1d.12xlarge  = 737
  }
}
