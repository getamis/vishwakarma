variable "name" {
  description = "(Required) Name of the cluster."
  type        = string
}

variable "container" {
  description = "Desired container repo and tag."
  type        = map(string)
  default = {
    repo = "quay.io/amis/aws-pod-identity-webhook"
    tag  = "v0.2.0"
  }
}

variable "kube_addons_dir_path" {
  description = "A path for installing addons."
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "pki_dir_path" {
  description = "A path for writting PKI."
  type        = string
  default     = "/etc/kubernetes/pki/pod-identity-webhook"
}

variable "webhook_flags" {
  description = "The flags of pod identity webhook. The variables need to follow https://github.com/aws/amazon-eks-pod-identity-webhook/blob/master/main.go. Do not use underline."
  default     = {}
}

variable "certs_validity_period_hours" {
  description = "Validity period of the self-signed certificates (in hours). Default is 10 years."
  type        = string

  // Default is provided only in this case
  // bacause *some* of etcd internal certs are still self-generated and need
  // this variable set
  default = 87600
}

variable "oidc_s3_bucket" {
  description = "Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters."
  type        = string
}

variable "oidc_api_audiences" {
  description = "the OIDC authenticator pre-introduction of API audiences"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "oidc_pub_key" {
  description = "The OIDC public key content"
  type        = string
  default     = ""
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = map(string)
  default     = {}
}
