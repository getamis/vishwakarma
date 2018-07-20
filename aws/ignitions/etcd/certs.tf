data "ignition_file" "etcd_ca" {
  path       = "${var.certs_path}/ca.crt"
  mode       = 0644
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.certs_config["ca_cert_pem"]}"
  }
}

data "ignition_file" "etcd_client_key" {
  path       = "${var.certs_path}/client.key"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.certs_config["client_key_pem"]}"
  }
}

data "ignition_file" "etcd_client_cert" {
  path       = "${var.certs_path}/client.crt"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.certs_config["client_cert_pem"]}"
  }
}

data "ignition_file" "etcd_server_key" {
  path       = "${var.certs_path}/server.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.certs_config["server_key_pem"]}"
  }
}

data "ignition_file" "etcd_server_cert" {
  path       = "${var.certs_path}/server.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.certs_config["server_cert_pem"]}"
  }
}

data "ignition_file" "etcd_peer_key" {
  path       = "${var.certs_path}/peer.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.certs_config["peer_key_pem"]}"
  }
}

data "ignition_file" "etcd_peer_cert" {
  path       = "${var.certs_path}/peer.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.certs_config["peer_cert_pem"]}"
  }
}
