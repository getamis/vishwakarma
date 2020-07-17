data "ignition_file" "aws_vpc_cni_yaml" {
  count = var.control_plane && var.network_plugin == "amazon-vpc" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/addons/aws-k8s-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/amazon-vpc/aws-vpc-cni.yaml.tpl", {
      image = "${local.containers["vpc_cni"].repo}:${local.containers["vpc_cni"].tag}"
    })
  }
}

data "ignition_file" "aws_cni_calico_yaml" {
  count = var.control_plane && var.network_plugin == "amazon-vpc" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/addons/calico-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/amazon-vpc/calico.yaml.tpl", {
      node_image       = "${local.containers["vpc_cni"].repo}:${local.containers["vpc_cni"].tag}"
      node_image       = "${local.containers["calico_node"].repo}:${local.containers["calico_node"].tag}"
      typha_image      = "${local.containers["calico_typha"].repo}:${local.containers["calico_typha"].tag}"
      autoscaler_image = "${local.containers["calico_autoscaler"].repo}:${local.containers["calico_autoscaler"].tag}"
    })
  }
}

data "ignition_file" "flannel_yaml" {
  count = var.control_plane && var.network_plugin == "flannel" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.etc_path}/addons/flannel-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/flannel/flannel.yaml.tpl", {
      image        = "${local.containers["flannel_cni"].repo}:${local.containers["flannel_cni"].tag}"
      cluster_cidr = var.pod_network_cidr
    })
  }
}
