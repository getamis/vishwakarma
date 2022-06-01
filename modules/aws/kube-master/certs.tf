module "kubernetes_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = "kubernetes"
    organization          = "kubernetes"
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "apiserver_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.kubernetes_ca.private_key_pem
    cert_pem = module.kubernetes_ca.cert_pem
  }

  cert_config = {
    common_name           = "kube-apiserver"
    organization          = "kube-master"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = compact(concat(
    [
      "localhost",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      // TODO: pass "cluster.local" from variable
      "kubernetes.default.svc.cluster.local",
      aws_elb.master_internal.dns_name,
    ],
  ))

  cert_ip_addresses = compact(concat(
    [
      "127.0.0.1",
      cidrhost(var.service_network_cidr, 1),
    ],
  ))

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  self_signed = true
}

module "admin_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.kubernetes_ca.private_key_pem
    cert_pem = module.kubernetes_ca.cert_pem
  }

  cert_config = {
    common_name           = "kubernetes-admin"
    organization          = "system:masters"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames    = []
  cert_ip_addresses = []

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "controller_manager_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.kubernetes_ca.private_key_pem
    cert_pem = module.kubernetes_ca.cert_pem
  }

  cert_config = {
    common_name           = "system:kube-controller-manager"
    organization          = "kube-master"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames    = []
  cert_ip_addresses = []

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "scheduler_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.kubernetes_ca.private_key_pem
    cert_pem = module.kubernetes_ca.cert_pem
  }

  cert_config = {
    common_name           = "system:kube-scheduler"
    organization          = "kube-master"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames    = []
  cert_ip_addresses = []

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "apiserver_kubelet_client_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.kubernetes_ca.private_key_pem
    cert_pem = module.kubernetes_ca.cert_pem
  }

  cert_config = {
    common_name           = "kube-apiserver-kubelet-client"
    organization          = "system:masters"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "apiserver_etcd_client_cert" {
  source = "../../tls/certificate"

  ca_config = {
    cert_pem = var.etcd_certs["ca_cert"]
    key_pem  = var.etcd_certs["ca_key"]
  }

  cert_config = {
    common_name           = "kube-apiserver-etcd-client"
    organization          = "system:masters"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "front_proxy_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = "front-proxy-ca"
    organization          = "kubernetes"
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "front_proxy_client_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.front_proxy_ca.private_key_pem
    cert_pem = module.front_proxy_ca.cert_pem
  }

  cert_config = {
    common_name           = "front-proxy-client"
    organization          = "kubernetes"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  self_signed = true
}

module "service_account" {
  source = "../../tls/private-key"
}