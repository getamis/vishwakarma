data "ignition_file" "etcd_ca" {
  path       = "${local.certs_path}/ca.crt"
  mode       = 420
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["ca_cert"]
  }
}

data "ignition_file" "etcd_client_cert" {
  path       = "${local.certs_path}/client.crt"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["client_cert"]
  }
}

data "ignition_file" "etcd_client_key" {
  path       = "${local.certs_path}/client.key"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["client_key"]
  }
}

data "ignition_file" "etcd_server_cert" {
  path       = "${local.certs_path}/server.crt"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["server_cert"]
  }
}

data "ignition_file" "etcd_server_key" {
  path       = "${local.certs_path}/server.key"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["server_key"]
  }
}

data "ignition_file" "etcd_peer_cert" {
  path       = "${local.certs_path}/peer.crt"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["peer_cert"]
  }
}

data "ignition_file" "etcd_peer_key" {
  path       = "${local.certs_path}/peer.key"
  mode       = 256
  uid        = var.cert_file_owner["uid"]
  gid        = var.cert_file_owner["gid"]
  filesystem = "root"

  content {
    content = var.certs["peer_key"]
  }
}
