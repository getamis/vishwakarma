output "worker_asg_name" {
  value = aws_autoscaling_group.worker.name
}

output "worker_launch_template_name" {
  value = aws_launch_template.worker.name
}

output "worker_role_name" {
  value = aws_iam_role.worker.name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}
