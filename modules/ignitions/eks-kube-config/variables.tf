variable "cluster_name" {
  type    = "string"
}

variable "cluster_endpoint" {
  type    = "string"
}

variable "certificate_authority_data" {
  type        = "string"
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  default     = ""
}

variable "kubeconfig_path" {
  description = "The kubeconfig path in the worker instance"
  default     = "/var/lib/kubelet"
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = "map"
  default     = {}
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = "list"
  default     = []
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = "list"
  default     = []
}