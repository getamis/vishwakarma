resource "aws_security_group_rule" "master_ingress" {
  type              = "ingress"
  security_group_id = local.master_sg_id

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.master.cidr_block]
  from_port   = 443
  to_port     = 443
}

module "ignition_kube_control_plane" {
  source = "../../ignitions/kube-control-plane"

  enable_auth  = var.enable_auth
  enable_irsa  = var.enable_irsa
  enable_audit = var.enable_audit

  kube_certs = {
    ca_cert_pem        = module.kube_root_ca.cert_pem
    apiserver_key_pem  = module.kube_api_server_cert.private_key_pem
    apiserver_cert_pem = module.kube_api_server_cert.cert_pem
  }

  etcd_certs = {
    ca_cert_pem     = var.etcd_certs_config["ca_cert_pem"]
    client_key_pem  = var.etcd_certs_config["client_key_pem"]
    client_cert_pem = var.etcd_certs_config["client_cert_pem"]
  }

  etcd_config = {
    endpoints = join(",", var.etcd_endpoints)
  }

  apiserver_config = {
    anonymous_auth          = false
    advertise_address       = "0.0.0.0"
    webhook_kubeconfig_path = var.webhook_kubeconfig_path
    audit_policy_path       = var.audit_policy_path
  }

  audit_log_backend = var.audit_log_backend
  oidc_issuer_confg = {
    issuer        = var.oidc_issuer
    api_audiences = var.oidc_api_audiences
  }
  service_account_pubkey = var.service_account_pubkey
  service_account_prikey = var.service_account_prikey
  oidc_issuer_pubkey     = var.oidc_issuer_pubkey
  oidc_issuer_prikey     = var.oidc_issuer_prikey

  cloud_provider = {
    name   = "aws"
    config = ""
  }

  cluster_config = {
    node_monitor_grace_period = "40s"
    pod_eviction_timeout      = "5m"
    service_cidr              = var.kube_service_cidr
    pod_cidr                  = var.kube_cluster_cidr
  }

  hyperkube = var.hyperkube_container
}
