data "ignition_file" "aws_vpc_cni_yaml" {
  count = var.control_plane && var.network_plugin == "amazon-vpc" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/aws-k8s-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/amazon-vpc/aws-vpc-cni.yaml.tpl", {
      image = "${local.container["vpc_cni"].repo}:${local.container["vpc_cni"].tag}"
    })
  }
}

data "ignition_file" "aws_cni_calico_yaml" {
  count = var.control_plane && var.network_plugin == "amazon-vpc" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/calico-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/amazon-vpc/calico.yaml.tpl", {
      node_image       = "${local.container["vpc_cni"].repo}:${local.container["vpc_cni"].tag}"
      node_image       = "${local.container["calico_node"].repo}:${local.container["calico_node"].tag}"
      typha_image      = "${local.container["calico_typha"].repo}:${local.container["calico_typha"].tag}"
      autoscaler_image = "${local.container["calico_autoscaler"].repo}:${local.container["calico_autoscaler"].tag}"
    })
  }
}

data "ignition_file" "flannel_yaml" {
  count = var.control_plane && var.network_plugin == "flannel" ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/flannel-cni.yaml"

  content {
    content = templatefile("${path.module}/templates/network-plugins/flannel/flannel.yaml.tpl", {
      image = "${local.container["flannel_cni"].repo}:${local.container["flannel_cni"].tag}"
      cluster_cidr = var.pod_network_cidr
    })
  }
}
