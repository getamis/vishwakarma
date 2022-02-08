resource "aws_security_group" "worker_group" {
  count       = var.enable_extra_sg ? 1 : 0

  name_prefix = "${var.name}-worker-${var.instance_config["name"]}-"
  description = "Security group for ${var.instance_config["name"]} workers."
  vpc_id      = local.vpc_id

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}-worker-${var.instance_config["name"]}",
    "Role", "k8s-worker"
  ))
}