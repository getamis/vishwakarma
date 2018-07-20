module "etcd_ca" {
  source = "../../tls/certificate-authority"

  cert_config = {
    common_name           = "etcd"
    organization          = "etcd"
    validity_period_hours = "${var.validity_period_hours}"
  }

  rsa_bits    = 2048
  self_signed = true
}

module "etcd_server_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = "${module.etcd_ca.algorithm}"
    key_pem   = "${module.etcd_ca.private_key_pem}"
    cert_pem  = "${module.etcd_ca.cert_pem}"
  }

  cert_config = {
    common_name           = "etcd"
    organization          = "etcd"
    validity_period_hours = "${var.validity_period_hours}"
  }

  cert_hostnames = [
    "localhost",
    "*.kube-etcd.kube-system.svc.cluster.local",
    "kube-etcd-client.kube-system.svc.cluster.local",
  ]

  cert_ip_addresses = [
    "127.0.0.1",
    "${cidrhost(var.service_cidr, 15)}",
    "${cidrhost(var.service_cidr, 20)}",
  ]

  cert_uses = ["server_auth"]

  self_signed = true
}

module "etcd_client_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = "${module.etcd_ca.algorithm}"
    key_pem   = "${module.etcd_ca.private_key_pem}"
    cert_pem  = "${module.etcd_ca.cert_pem}"
  }

  cert_config = {
    common_name           = "etcd"
    organization          = "etcd"
    validity_period_hours = "${var.validity_period_hours}"
  }

  cert_uses = ["client_auth"]

  self_signed = true
}

module "etcd_peer_cert" {
  source = "../../tls/certificate"

  ca_config = {
    algorithm = "${module.etcd_ca.algorithm}"
    key_pem   = "${module.etcd_ca.private_key_pem}"
    cert_pem  = "${module.etcd_ca.cert_pem}"
  }

  cert_config = {
    common_name           = "etcd"
    organization          = "etcd"
    validity_period_hours = "${var.validity_period_hours}"
  }

  cert_hostnames = [
    "*.kube-etcd.kube-system.svc.cluster.local",
    "kube-etcd-client.kube-system.svc.cluster.local",
  ]

  cert_ip_addresses = [
    "127.0.0.1",
    "${cidrhost(var.service_cidr, 15)}",
    "${cidrhost(var.service_cidr, 20)}",
  ]

  cert_uses = ["server_auth", "client_auth"]

  self_signed = true
}
