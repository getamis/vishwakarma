output "worker_asg_name" {
  value = aws_autoscaling_group.worker.name
}

output "worker_launch_template_name" {
  value = aws_launch_template.worker.name
}

output "worker_role_name" {
  value = length(aws_iam_role.worker[*].name) > 0 ? aws_iam_role.worker[0].name : var.role_name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}

output "worker_extra_sg_id" {
  value = var.enable_extra_sg ? aws_security_group.worker_group[0].id : "N/A"
}