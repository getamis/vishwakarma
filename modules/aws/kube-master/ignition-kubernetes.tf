resource "random_id" "bootstrap_token_id" {
  byte_length = 3
}

resource "random_id" "bootstrap_token_secret" {
  byte_length = 8
}

resource "random_password" "encryption_secret" {
  length  = 32
  special = true
}

module "ignition_kubernetes" {
  source = "../../ignitions/kubernetes"

  control_plane         = true
  binaries              = var.binaries
  containers            = var.containers
  apiserver_secure_port = var.apiserver_secure_port
  service_network_cidr  = var.service_network_cidr
  pod_network_cidr      = var.cluster_network_cidr
  network_plugin        = var.network_plugin
  internal_endpoint     = "https://${aws_elb.master_internal.dns_name}"
  etcd_endpoints        = join(",", var.etcd_endpoints)

  tls_bootstrap_token = {
    id     = random_id.bootstrap_token_id.hex
    secret = random_id.bootstrap_token_secret.hex
  }

  kubelet_config = var.kubelet_extra_config

  cloud_config = {
    provider = "aws"
    path     = ""
  }

  kube_proxy_config = var.kube_proxy_config
  coredns_config = merge(var.coredns_config, {
    replicas = parseint(local.instance_config["count"], 3)
  })

  kubelet_flags = merge(var.extra_flags["kubelet"], {
    node-labels          = join(",", var.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  apiserver_flags          = var.extra_flags["apiserver"]
  controller_manager_flags = var.extra_flags["controller_manager"]
  scheduler_flags          = var.extra_flags["scheduler"]
  audit_log_flags          = var.extra_flags["audit_log"]
  audit_log_policy_content = var.audit_log_policy_content
  encryption_secret        = random_password.encryption_secret.result
  enable_iam_auth          = var.enable_iam_auth
  auth_webhook_config_path = var.auth_webhook_config_path
  enable_irsa              = var.enable_irsa
  oidc_config              = var.oidc_config

  certs = {
    etcd_ca_cert = var.etcd_certs["ca_cert"]

    ca_cert                       = module.kubernetes_ca.cert_pem
    ca_key                        = module.kubernetes_ca.private_key_pem
    apiserver_cert                = module.apiserver_cert.cert_pem
    apiserver_key                 = module.apiserver_cert.private_key_pem
    apiserver_kubelet_client_cert = module.apiserver_kubelet_client_cert.cert_pem
    apiserver_kubelet_client_key  = module.apiserver_kubelet_client_cert.private_key_pem
    apiserver_etcd_client_cert    = module.apiserver_etcd_client_cert.cert_pem
    apiserver_etcd_client_key     = module.apiserver_etcd_client_cert.private_key_pem
    front_proxy_ca_cert           = module.front_proxy_ca.cert_pem
    front_proxy_ca_key            = module.front_proxy_ca.private_key_pem
    front_proxy_client_cert       = module.front_proxy_client_cert.cert_pem
    front_proxy_client_key        = module.front_proxy_client_cert.private_key_pem
    sa_pub                        = module.service_account.public_key_pem
    sa_key                        = module.service_account.private_key_pem
  }

  kubelet_cert = {
    algo   = lower(module.kubernetes_ca.algorithm)
    size   = 2048
    expiry = "${var.certs_validity_period_hours}h"
  }
}
