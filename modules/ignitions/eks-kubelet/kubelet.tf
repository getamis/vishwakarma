data "ignition_file" "client_ca_file" {
  path       = "${var.client_ca_file_path}"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${base64decode(var.certificate_authority_data)}"
  }
}

data "template_file" "kubelet" {
  template = "${file("${path.module}/resources/services/kubelet.service")}"

  vars {
    kubelet_flag_cni_bin_dir          = "${var.kubelet_flag_cni_bin_dir != "" ? "--cni-bin-dir=${var.kubelet_flag_cni_bin_dir}" : ""}"
    kubelet_flag_config               = "${var.kubelet_flag_config != "" ? "--config=${var.kubelet_flag_config}" : ""}"
    kubelet_flag_container_runtime = "${var.kubelet_flag_container_runtime != "" ? "--container-runtime=${var.kubelet_flag_container_runtime}" : ""}"
    kubelet_flag_kubeconfig = "${var.kubelet_flag_kubeconfig != "" ? "--kubeconfig=${var.kubelet_flag_kubeconfig}" : ""}"
    kubelet_flag_max_pods = "--max-pods=${lookup(var.eni_max_pods, var.instance_type, 10)}"
    kubelet_flag_node_labels          = "${var.kubelet_flag_node_labels != "" ? "--node-labels=${var.kubelet_flag_node_labels}" : ""}"
    kubelet_flag_pod_infra_container_image = "--pod-infra-container-image=${replace(var.kubelet_flag_pod_infra_container_image, "REGION", var.aws_region)}"
    kubelet_flag_pod_manifest_path    = "${var.kubelet_flag_pod_manifest_path != "" ? "--pod-manifest-path=${var.kubelet_flag_pod_manifest_path}" : ""}"
    kubelet_flag_register_with_taints = "${var.kubelet_flag_register_with_taints != "" ? "--register-with-taints=${var.kubelet_flag_register_with_taints}" : ""}"
    kubelet_flag_extra_flags          = "${length(var.kubelet_flag_extra_flags) > 0 ? join(" ", var.kubelet_flag_extra_flags) : ""}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = "${data.template_file.kubelet.rendered}"
}