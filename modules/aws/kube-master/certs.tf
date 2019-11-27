module "kube_root_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = "kubernetes"
    organization          = "kubernetes"
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "kube_api_server_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = module.kube_root_ca.algorithm
    key_pem   = module.kube_root_ca.private_key_pem
    cert_pem  = module.kube_root_ca.cert_pem
  }

  cert_config = {
    common_name           = "kube-apiserver"
    organization          = "kube-master"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = compact(concat(
    list(
      "localhost",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster.local",
      aws_elb.master_internal.dns_name,
    ),
  ))

  cert_ip_addresses = compact(concat(
    list(
      "127.0.0.1",
      "${cidrhost(var.kube_service_cidr, 1)}",
    ),
  ))

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]

  self_signed = true
}

module "kube_kubelet_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = module.kube_root_ca.algorithm
    key_pem   = module.kube_root_ca.private_key_pem
    cert_pem  = module.kube_root_ca.cert_pem
  }

  cert_config = {
    common_name           = "kubelet"
    organization          = "system:masters"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]

  self_signed = true
}
