
locals {
  kubernetes_minior_version = parseint(split(".", var.hyperkube["image_tag"])[1], 10)

}

data "template_file" "kubelet_env" {
  template = file("${path.module}/templates/kubelet.env.tpl")

  vars = {
    kubelet_image_url = var.hyperkube["image_path"]
    kubelet_image_tag = var.hyperkube["image_tag"]
  }
}

data "ignition_file" "kubelet_env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 420

  content {
    content = data.template_file.kubelet_env.rendered
  }
}

data "template_file" "kubelet" {
  template = file("${path.module}/templates/kubelet.service.tpl")

  vars = {
    kubelet_flag_cloud_provider       = var.kubelet_flag_cloud_provider != "" ? "--cloud-provider=${var.kubelet_flag_cloud_provider}" : ""
    kubelet_flag_cloud_config         = var.kubelet_flag_cloud_config != "" ? "--cloud-config=/etc/kubernetes/cloud/config" : ""
    kubelet_flag_cluster_dns          = var.kubelet_flag_cluster_dns != "" ? "--cluster-dns=${var.kubelet_flag_cluster_dns}" : ""
    kubelet_flag_cni_bin_dir          = var.kubelet_flag_cni_bin_dir != "" ? "--cni-bin-dir=${var.kubelet_flag_cni_bin_dir}" : ""
    kubelet_flag_pod_manifest_path    = var.kubelet_flag_pod_manifest_path != "" ? "--pod-manifest-path=${var.kubelet_flag_pod_manifest_path}" : ""
    kubelet_flag_node_labels          = var.kubelet_flag_node_labels != "" ? "--node-labels=${var.kubelet_flag_node_labels}" : ""
    kubelet_flag_register_with_taints = var.kubelet_flag_register_with_taints != "" ? "--register-with-taints=${var.kubelet_flag_register_with_taints}" : ""
    kubelet_flag_extra_flags          = length(var.kubelet_flag_extra_flags) > 0 ? join(" ", var.kubelet_flag_extra_flags) : ""
    kubelet_flag_allow_privileged     = local.kubernetes_minior_version >= 15 ? "" : "--allow-privileged"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = data.template_file.kubelet.rendered
}

