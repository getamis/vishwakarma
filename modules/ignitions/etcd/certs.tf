data "ignition_file" "etcd_ca" {
  path = "${var.certs_path}/ca.crt"
  mode = 420
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]


  content {
    content = var.certs_config["ca_cert_pem"]
  }
}

data "ignition_file" "etcd_client_key" {
  path = "${var.certs_path}/client.key"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]


  content {
    content = var.certs_config["client_key_pem"]
  }
}

data "ignition_file" "etcd_client_cert" {
  path = "${var.certs_path}/client.crt"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]


  content {
    content = var.certs_config["client_cert_pem"]
  }
}

data "ignition_file" "etcd_server_key" {
  path = "${var.certs_path}/server.key"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]


  content {
    content = var.certs_config["server_key_pem"]
  }
}

data "ignition_file" "etcd_server_cert" {
  path = "${var.certs_path}/server.crt"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]


  content {
    content = var.certs_config["server_cert_pem"]
  }
}

data "ignition_file" "etcd_peer_key" {
  path = "${var.certs_path}/peer.key"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]

  content {
    content = var.certs_config["peer_key_pem"]
  }
}

data "ignition_file" "etcd_peer_cert" {
  path = "${var.certs_path}/peer.crt"
  mode = 256
  uid  = var.cert_file_owner["uid"]
  gid  = var.cert_file_owner["gid"]

  content {
    content = var.certs_config["peer_cert_pem"]
  }
}
