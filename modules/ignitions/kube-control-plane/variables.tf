variable "manifest_path" {
  type        = "string"
  default     = "/etc/kubernetes/manifests"
  description = "(Optional) Path to the directory containing static manifests"
}

variable "addon_path" {
  type        = "string"
  default     = "/etc/kubernetes/addons"
  description = "(Optional) The absolute path of the addons to be installed."
}

variable "secret_path" {
  type        = "string"
  default     = "/etc/kubernetes/secrets"
  description = "(Optional) Path to the directory containing static secrets"
}

variable "kube_certs" {
  type = "map"

  default = {
    # ca_cert_pem        = ""
    # apiserver_key_pem  = ""
    # apiserver_cert_pem = ""
  }
}

variable "etcd_certs" {
  type = "map"

  default = {
    # ca_cert_pem     = ""
    # client_key_pem  = ""
    # client_cert_pem = ""
  }
}

variable "etcd_config" {
  type = "map"

  default = {
    endpoints = ""
  }

  description = <<EOF
  endpoints: The comma separated list of etcd endpoints (e.g., "http://etcd1:2379,http://etcd2:2379").
  EOF
}

variable "apiserver_config" {
  type = "map"

  default = {
    anonymous_auth    = false
    advertise_address = "0.0.0.0"
    auth_webhook_path = ""
    audit_policy_path = ""
  }
}

variable "audit_log_backend" {
  type = "map"
  default = {}
}


variable "cloud_provider" {
  type = "map"

  default = {
    name   = "aws"
    config = ""
  }
}

variable "cluster_config" {
  type = "map"

  default = {
    node_monitor_grace_period = "40s"
    pod_eviction_timeout      = "5m"
    service_cidr              = "10.3.0.0/16"
    pod_cidr                  = "10.2.0.0/16"
  }

  description = <<EOF
  node_monitor_grace_period: Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status. N must be stricly > 1.
  pod_eviction_timeout: The grace period for deleting pods on failed nodes. The eviction process will start after node_monitor_grace_period + pod_eviction_timeout.
  EOF
}

variable "hyperkube" {
  type = "map"

  default = {
    image_path = "gcr.io/google-containers/hyperkube-amd64"
    image_tag  = "v1.13.4"
  }

  description = "The hyperkube container image path and tag"
}
