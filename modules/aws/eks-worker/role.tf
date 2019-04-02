locals {
  worker_role_name = "${var.cluster_name}-worker-${var.worker_config["name"]}"
}

data "aws_iam_instance_profile" "worker" {
  name = "${local.worker_role_name}"
}

data "aws_iam_role" "worker" {
  name = "${local.worker_role_name}"
}

resource "aws_iam_role_policy_attachment" "worker" {
  count      = "${length(var.extra_worker_policy_arns)}"
  policy_arn = "${var.extra_worker_policy_arns[count.index]}"
  role       = "${local.worker_role_name}"
}