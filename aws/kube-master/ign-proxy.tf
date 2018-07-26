module "ignition_kube_addon_proxy" {
  source = "../ignitions/kube-addon-proxy"

  cluster_cidr = "${var.kube_cluster_cidr}"

  hyperkube = {
    image_path = "quay.io/coreos/hyperkube"
    image_tag  = "${var.version}_coreos.0"
  }
}
