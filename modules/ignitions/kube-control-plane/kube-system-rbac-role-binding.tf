data "template_file" "kube_system_rbac_role_binding_yaml" {
  template = file("${path.module}/resources/kubernetes/addon/kube-system-rbac-role-binding.yaml")
}

data "ignition_file" "kube_system_rbac_role_binding_yaml" {
  filesystem = local.filesystem
  mode       = local.mode
  path       = "${pathexpand(var.addon_path)}/kube-system-rbac-role-binding.yaml"

  content {
    content = data.template_file.kube_system_rbac_role_binding_yaml.rendered
  }
}
