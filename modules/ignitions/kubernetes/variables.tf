variable "control_plane" {
  type    = bool
  default = false
}

variable "kubernetes_version" {
  description = "Kubernetes cluster version."
  type        = string
  default     = "v1.18.6"
}

variable "binaries" {
  description = "Desired binaries(kubelet, kubectl, and cni) url and chechsum."
  type = map(object({
    url      = string
    chechsum = string
  }))
  default = {}
}

variable "containers" {
  description = "Desired containers(kube-apiserver, kube-controller-manager, cfssl, coredns, and so on) repo and tag."
  type = map(object({
    repo = string
    tag  = string
  }))
  default = {}
}

variable "internal_endpoint" {
  description = "The internal endpoint of kube-apiserver."
  type        = string
  default     = "https://127.0.0.1"
}

variable "apiserver_secure_port" {
  type    = number
  default = 6443
}

variable "service_network_cidr" {
  description = "This is the virtual IP address that will be assigned to services created on Kubernetes."
  type        = string
  default     = "10.96.0.0/12"
}

variable "pod_network_cidr" {
  description = "The CIDR pool used to assign IP addresses to pods in the cluster."
  type        = string
  default     = "10.244.0.0/16"
}

variable "network_plugin" {
  description = "Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "amazon-vpc"
}

variable "tls_bootstrap_token" {
  description = "The token uses to authenticate API server."
  type = object({
    id     = string
    secret = string
  })
}

variable "cloud_config" {
  description = "The cloud provider configuration."
  type = object({
    provider = string
    path     = string
  })
  default = {
    provider = ""
    path     = ""
  }
}

variable "kubelet_cert" {
  description = "The kubelet cert args."
  default     = {}
}

variable "kubelet_config" {
  description = "The configuration of kubelet. The variables need to follow https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubelet/config/v1beta1/types.go. Do not use underline."
  default     = {}
}

variable "kubelet_flags" {
  description = "The flags of kubelet. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/. Do not use underline."
  default     = {}
}

variable "apiserver_flags" {
  description = "The flags of kube-apiserver. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/. Do not use underline."
  default     = {}
}

variable "controller_manager_flags" {
  description = "The flags of kube-controller-manager. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/. Do not use underline."
  default     = {}
}

variable "scheduler_flags" {
  description = "The flags of kube-scheduler. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/. Do not use underline."
  default     = {}
}

variable "kubeconfig_paths" {
  description = "The kubeconfig paths for Kubernetes components"
  type        = map(string)
  default     = {}
}

variable "certs" {
  description = "The kubernetes and etcd certificate."
  type        = map(string)
  default     = {}
}

variable "etcd_endpoints" {
  description = "The comma separated list of etcd endpoints (e.g., 'http://etcd1:2379,http://etcd2:2379')."
  type        = string
  default     = ""
}

variable "audit_log_flags" {
  description = "The flags of audit log in kube-apiserver. The variables need to follow https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/. Do not use underline."
  default     = {}
}

variable "audit_log_policy_content" {
  description = "The policy content for auditing log."
  type        = string
  default     = ""
}

variable "encryption_secret" {
  description = "The secret key for encrypting"
  type        = string
  default     = ""
}

variable "enable_iam_auth" {
  description = "Enable AWS IAM authenticator or not."
  type        = bool
  default     = false
}

variable "auth_webhook_config_path" {
  description = "The path of webhook config for kube-apiserver."
  default     = "/etc/kubernetes/config/aws-iam-authenticator/kubeconfig"
}

variable "enable_irsa" {
  description = "Enable AWS IAM role service account or not."
  type        = bool
  default     = false
}

variable "oidc_config" {
  description = "The service account config to enable pod identity feature."
  type = object({
    issuer        = string
    api_audiences = string
  })
  default = {
    issuer        = ""
    api_audiences = ""
  }
}

variable "kube_proxy_config" {
  description = "The configuration of kube-proxy. The variables need to follow https://github.com/kubernetes/kube-proxy/blob/master/config/v1alpha1/types.go. Do not use underline."
  default     = {}
}

variable "coredns_config" {
  description = "The configuration of CoreDNS."
  default     = {}
}

// TODO(k2r2bai): add support for setting feature gates.
variable "feature_gates" {
  description = "A set of key=value pairs that describe feature gates for alpha/experimental features."
  type        = map(bool)
  default     = {}
}
