data "template_file" "kube_controller_manager_yaml" {
  template = file("${path.module}/resources/kubernetes/manifests/kube-controller-manager.yaml")

  vars = {
    hyperkube_image           = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    kubernetes_version        = element(split("_", var.hyperkube["image_tag"]), 0)
    secret_path               = var.secret_path
    node_monitor_grace_period = var.cluster_config["node_monitor_grace_period"]
    pod_eviction_timeout      = var.cluster_config["pod_eviction_timeout"]

    cluster_cidr = var.cluster_config["pod_cidr"]

    cloud_provider             = var.cloud_provider["name"]
    cloud_provider_config_flag = var.cloud_provider["config"] != "" ? "- --cloud-config=/etc/kubernetes/cloud/config" : "# no cloud provider config given"
  }
}

data "ignition_file" "kube_controller_manager_yaml" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${pathexpand(var.manifest_path)}/kube-controller-manager.yaml"

  content {
    content = data.template_file.kube_controller_manager_yaml.rendered
  }
}
