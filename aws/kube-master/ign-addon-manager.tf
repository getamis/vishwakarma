module "ignition_kube_addon_manager" {
  source = "../ignitions/kube-addon-manager"

  hyperkube = {
    image_path = "quay.io/coreos/hyperkube"
    image_tag  = "${var.version}_coreos.0"
  }
}
