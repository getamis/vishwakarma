locals {
  filesystem = "root"
  mode       = 420
}

data "template_file" "aws_vpc_cni_yaml" {
  template = file("${path.module}/resources/aws-k8s-cni.yaml")
  vars = {
    vpc_cni_image = var.container_images["vpc_cni"]
  }
}

data "ignition_file" "aws_vpc_cni_yaml" {
  filesystem = local.filesystem
  mode       = local.mode
  path       = "${pathexpand(var.addon_path)}/aws-k8s-cni.yaml"
  content {
    content = data.template_file.aws_vpc_cni_yaml.rendered
  }
}

data "template_file" "calico_yaml" {
  template = file("${path.module}/resources/calico.yaml")
  vars = {
    calico_node_image    = var.container_images["calico_node"]
    calico_typha_image   = var.container_images["calico_typha"]
    k8s_autoscaler_image = var.container_images["k8s_autoscaler"]
  }
}

data "ignition_file" "calico_yaml" {
  filesystem = local.filesystem
  mode       = local.mode
  path       = "${pathexpand(var.addon_path)}/calico.yaml"
  content {
    content = data.template_file.calico_yaml.rendered
  }
}
