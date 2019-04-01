data "aws_caller_identity" "current" {}

data "template_file" "worker_role_arns" {
  count    = "${length(var.worker_groups)}"
  template = "${file("${path.module}/resources/worker-role.tpl")}"

  vars {
    worker_role_arn = "${aws_iam_role.workers.*.arn[count.index]}"
  }
}

data "template_file" "map_users" {
  count    = "${var.map_users_count}"
  template = "${file("${path.module}/resources/config-map-aws-auth-map_users.yaml.tpl")}"

  vars {
    user_arn = "${lookup(var.map_users[count.index], "user_arn")}"
    username = "${lookup(var.map_users[count.index], "username")}"
    group    = "${lookup(var.map_users[count.index], "group")}"
  }
}

data "template_file" "map_roles" {
  count    = "${var.map_roles_count}"
  template = "${file("${path.module}/resources/config-map-aws-auth-map_roles.yaml.tpl")}"

  vars {
    role_arn = "${lookup(var.map_roles[count.index], "role_arn")}"
    username = "${lookup(var.map_roles[count.index], "username")}"
    group    = "${lookup(var.map_roles[count.index], "group")}"
  }
}

data "template_file" "map_accounts" {
  count    = "${var.map_accounts_count}"
  template = "${file("${path.module}/resources/config-map-aws-auth-map_accounts.yaml.tpl")}"

  vars {
    account_number = "${element(var.map_accounts, count.index)}"
  }
}

data "template_file" "config_map_aws_auth" {
  template = "${file("${path.module}/resources/config-map-aws-auth.yaml.tpl")}"

  vars {
    worker_role_arn = "${join("", distinct( data.template_file.worker_role_arns.*.rendered))}"
    map_users       = "${join("", data.template_file.map_users.*.rendered)}"
    map_roles       = "${join("", data.template_file.map_roles.*.rendered)}"
    map_accounts    = "${join("", data.template_file.map_accounts.*.rendered)}"
  }
}

resource "local_file" "config_map_aws_auth" {
  content  = "${data.template_file.config_map_aws_auth.rendered}"
  filename = "${var.config_output_path}/config-map-aws-auth_${local.cluster_name}.yaml"
  count    = "${var.write_aws_auth_config ? 1 : 0}"
}

resource "null_resource" "update_config_map_aws_auth" {
  depends_on = ["aws_eks_cluster.vishwakarma"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
for i in `seq 1 10`; do \
echo "${null_resource.update_config_map_aws_auth.triggers.kube_config_map_rendered}" > kube_config.yaml & \
echo "${null_resource.update_config_map_aws_auth.triggers.config_map_rendered}" > aws_auth_configmap.yaml & \
kubectl apply -f aws_auth_configmap.yaml --kubeconfig kube_config.yaml && break || \
sleep 10; \
done; \
rm aws_auth_configmap.yaml kube_config.yaml;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }

  triggers {
    kube_config_map_rendered = "${module.ignition_kubeconfig.rendered}"
    config_map_rendered      = "${data.template_file.config_map_aws_auth.rendered}"
    endpoint                 = "${aws_eks_cluster.vishwakarma.endpoint}"
  }

  count = "${var.manage_aws_auth ? 1 : 0}"
}