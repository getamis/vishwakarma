data "aws_region" "current" {}

module "etcd_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = "etcd-ca"
    organization          = "etcd"
    validity_period_hours = var.certs_validity_period_hours
  }

  rsa_bits    = 2048
  self_signed = true
}

module "etcd_server_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.etcd_ca.private_key_pem
    cert_pem = module.etcd_ca.cert_pem
  }

  cert_config = {
    common_name           = "etcd-server"
    organization          = "etcd"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = compact(concat(
    [
      "localhost",
      "*.kube-etcd.kube-system.svc.cluster.local",
      "kube-etcd-client.kube-system.svc.cluster.local",
      local.discovery_service,
      "*.${local.discovery_service}",
      "*.${data.aws_region.current.name}.compute.internal"
    ],
    var.certs_hostnames,
  ))

  cert_ip_addresses = compact(concat(
    ["127.0.0.1"],
    var.certs_ip_addresses,
  ))

  cert_uses = [
    "digital_signature",
    "server_auth",
    "client_auth"
  ]

  self_signed = true
}

module "etcd_client_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.etcd_ca.private_key_pem
    cert_pem = module.etcd_ca.cert_pem
  }

  cert_config = {
    common_name           = "etcd-client"
    organization          = "etcd"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_uses = [
    "digital_signature",
    "client_auth"
  ]

  self_signed = true
}

module "etcd_peer_cert" {
  source = "../../tls/certificate"

  ca_config = {
    key_pem  = module.etcd_ca.private_key_pem
    cert_pem = module.etcd_ca.cert_pem
  }

  cert_config = {
    common_name           = "etcd-peer"
    organization          = "etcd"
    validity_period_hours = var.certs_validity_period_hours
  }

  cert_hostnames = compact(concat(
    [
      "*.kube-etcd.kube-system.svc.cluster.local",
      "kube-etcd-client.kube-system.svc.cluster.local",
      local.discovery_service,
      "*.${local.discovery_service}",
      "*.${data.aws_region.current.name}.compute.internal"
    ],
    var.certs_hostnames,
  ))

  cert_ip_addresses = compact(concat(
    ["127.0.0.1"],
    var.certs_ip_addresses,
  ))

  cert_uses = [
    "digital_signature",
    "server_auth",
    "client_auth"
  ]

  self_signed = true
}
