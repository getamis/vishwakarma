variable "manifest_path" {
  description = "(Optional) Path to the directory containing static manifests"
  type        = string
  default     = "/etc/kubernetes/manifests"
}

variable "addon_path" {
  description = "(Optional) The absolute path of the addons to be installed."
  type        = string
  default     = "/etc/kubernetes/addons"
}

variable "secret_path" {
  description = "(Optional) Path to the directory containing static secrets"
  type        = string
  default     = "/etc/kubernetes/secrets"
}

variable "kube_certs" {
  description = "The kubernetes certificate"
  type        = map(string)
  default = {
    # ca_cert_pem        = ""
    # apiserver_key_pem  = ""
    # apiserver_cert_pem = ""
  }
}

variable "etcd_certs" {
  description = "The ectd certificate"
  type        = map(string)
  default = {
    # ca_cert_pem     = ""
    # client_key_pem  = ""
    # client_cert_pem = ""
  }
}

variable "etcd_config" {
  description = <<EOF
  endpoints: The comma separated list of etcd endpoints (e.g., "http://etcd1:2379,http://etcd2:2379").
  EOF
  type        = map(string)
  default = {
    endpoints = ""
  }
}

variable "apiserver_config" {
  type = map(string)
  default = {
    anonymous_auth    = false
    advertise_address = "0.0.0.0"
    auth_webhook_path = ""
    audit_policy_path = ""
  }
}

variable "audit_log_backend" {
  type    = map(string)
  default = {}
}

variable "oidc_issuer_confg" {
  description = "The service account config to enable pod identity feature"
  type = object({
    issuer        = string
    api_audiences = string
  })
  default = {
    issuer        = ""
    api_audiences = ""
  }
}

variable "cloud_provider" {
  type = map(string)
  default = {
    name   = "aws"
    config = ""
  }
}

variable "cluster_config" {
  description = <<EOF
  node_monitor_grace_period: Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status. N must be stricly > 1.
  pod_eviction_timeout: The grace period for deleting pods on failed nodes. The eviction process will start after node_monitor_grace_period + pod_eviction_timeout.
  EOF
  type        = map(string)
  default = {
    node_monitor_grace_period = "40s"
    pod_eviction_timeout      = "5m"
    service_cidr              = "10.3.0.0/16"
    pod_cidr                  = "10.2.0.0/16"
  }
}

variable "hyperkube" {
  description = "The hyperkube container image path and tag"
  type        = map(string)
}
