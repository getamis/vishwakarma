data "template_file" "kube_apiserver_yaml" {
  template = "${file("${path.module}/resources/kubernetes/manifests/kube-apiserver.yaml")}"

  vars {
    hyperkube_image = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    secret_path     = "${var.secret_path}"

    etcd_servers   = "${var.etcd_config["endpoints"]}"
    etcd_ca_flag   = "${var.etcd_certs["ca_cert_pem"] != "" ? "- --etcd-cafile=${var.secret_path}/etcd-client-ca.crt" : "# no etcd-client-ca.crt given" }"
    etcd_cert_flag = "${var.etcd_certs["client_cert_pem"] != "" ? "- --etcd-certfile=${var.secret_path}/etcd-client.crt" : "# no etcd-client.crt given" }"
    etcd_key_flag  = "${var.etcd_certs["client_key_pem"] != "" ? "- --etcd-keyfile=${var.secret_path}/etcd-client.key" : "# no etcd-client.key given" }"

    anonymous_auth    = "${var.apiserver_config["anonymous_auth"]}"
    advertise_address = "${var.apiserver_config["advertise_address"]}"
    service_cidr      = "${var.cluster_config["service_cidr"]}"

    cloud_provider             = "${var.cloud_provider["name"]}"
    cloud_provider_config_flag = "${var.cloud_provider["config"] != "" ? "- --cloud-config=/etc/kubernetes/cloud/config" : "# no cloud provider config given"}"
  }
}

data "ignition_file" "kube_apiserver_yaml" {
  filesystem = "${local.filesystem}"
  mode       = "${local.mode}"

  path = "${pathexpand(var.manifest_path)}/kube-apiserver.yaml"

  content {
    content = "${data.template_file.kube_apiserver_yaml.rendered}"
  }
}
