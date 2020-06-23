resource "tls_private_key" "service_account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

data "ignition_file" "kube_ca_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/ca.crt"

  content {
    content = var.kube_certs["ca_cert_pem"]
  }
}

data "ignition_file" "apiserver_key_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/apiserver.key"

  content {
    content = var.kube_certs["apiserver_key_pem"]
  }
}

data "ignition_file" "apiserver_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/apiserver.crt"

  content {
    content = var.kube_certs["apiserver_cert_pem"]
  }
}

data "ignition_file" "controller_manager_key_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/controller-manager.key"

  content {
    content = var.kube_certs["controller_manager_key_pem"]
  }
}

data "ignition_file" "controller_manager_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/controller-manager.crt"

  content {
    content = var.kube_certs["controller_manager_cert_pem"]
  }
}

data "ignition_file" "service_account_pubkey" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/service-account.pub"

  content {
    content = tls_private_key.service_account.public_key_pem
  }
}

data "ignition_file" "service_account_prikey" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/service-account.key"

  content {
    content = tls_private_key.service_account.private_key_pem
  }
}

data "ignition_file" "etcd_ca_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/etcd-client-ca.crt"

  content {
    content = var.etcd_certs["ca_cert_pem"]
  }
}

data "ignition_file" "etcd_client_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/etcd-client.crt"

  content {
    content = var.etcd_certs["client_cert_pem"]
  }
}

data "ignition_file" "etcd_client_key_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "/etc/kubernetes/secrets/etcd-client.key"

  content {
    content = var.etcd_certs["client_key_pem"]
  }
}
