data "ignition_file" "kubernetes_ca_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/ca.crt"

  content {
    content = var.certs["ca_cert"]
  }
}

data "ignition_file" "kubernetes_ca_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/ca.key"

  content {
    content = var.certs["ca_key"]
  }
}

data "ignition_file" "front_proxy_ca_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/front-proxy-ca.crt"

  content {
    content = var.certs["front_proxy_ca_cert"]
  }
}

data "ignition_file" "front_proxy_ca_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/front-proxy-ca.key"

  content {
    content = var.certs["front_proxy_ca_key"]
  }
}

data "ignition_file" "apiserver_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver.crt"

  content {
    content = var.certs["apiserver_cert"]
  }
}

data "ignition_file" "apiserver_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver.key"

  content {
    content = var.certs["apiserver_key"]
  }
}

data "ignition_file" "apiserver_kubelet_client_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver-kubelet-client.crt"

  content {
    content = var.certs["apiserver_kubelet_client_cert"]
  }
}

data "ignition_file" "apiserver_kubelet_client_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver-kubelet-client.key"

  content {
    content = var.certs["apiserver_kubelet_client_key"]
  }
}

data "ignition_file" "apiserver_etcd_client_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver-etcd-client.crt"

  content {
    content = var.certs["apiserver_etcd_client_cert"]
  }
}

data "ignition_file" "apiserver_etcd_client_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/apiserver-etcd-client.key"

  content {
    content = var.certs["apiserver_etcd_client_key"]
  }
}

data "ignition_file" "front_proxy_client_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/front-proxy-client.crt"

  content {
    content = var.certs["front_proxy_client_cert"]
  }
}

data "ignition_file" "front_proxy_client_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/front-proxy-client.key"

  content {
    content = var.certs["front_proxy_client_key"]
  }
}

data "ignition_file" "service_account_public_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/sa.pub"

  content {
    content = var.certs["sa_pub"]
  }
}

data "ignition_file" "service_account_private_key" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/pki/sa.key"

  content {
    content = var.certs["sa_key"]
  }
}

data "ignition_file" "etcd_ca_cert" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420

  path = "${local.etc_path}/pki/etcd/ca.crt"

  content {
    content = var.certs["etcd_ca_cert"]
  }
}
