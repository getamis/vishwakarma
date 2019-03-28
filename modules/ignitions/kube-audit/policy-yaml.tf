data "template_file" "policy_yaml" {
  template = "${file("${path.module}/resources/kubernetes/policy.yaml")}"

  vars {
    audit_policy = "${var.audit_policy}"
  }
}

data "ignition_file" "policy_yaml" {
  filesystem = "${local.filesystem}"
  mode       = "${local.mode}"

  path = "${pathexpand(var.audit_policy_path)}/policy.yaml"

  content {
    content = "${data.template_file.policy_yaml.rendered}"
  }
}
