output "id" {
  value       = var.name
  description = "Kubernetes cluster name."
}

output "endpoint" {
  value       = module.master.endpoint
  description = "Kubernetes cluster endpoint."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "The VPC id used by K8S"
}

output "ignition_s3_bucket" {
  value       = aws_s3_bucket.ignition.id
  description = "The S3 bucket for storing provision ignition file"
}

output "master_sg_ids" {
  value       = [module.master.master_sg_id]
  description = "The security group which used by K8S master"
}

output "worker_sg_ids" {
  value       = [aws_security_group.workers.id]
  description = "The security gruop for worker group"
}

output "master_internal_elb_name" {
  value = module.master.master_internal_elb_name
}

output "master_role_name" {
  value = module.master.default_role_name
}

output "master_launch_template_name" {
  value = module.master.master_launch_template_name
}

output "master_asg_name" {
  value = module.master.master_asg_name
}

output "etcd_role_name" {
  value = module.etcd.default_role_name
}

output "service_account_pub_key" {
  sensitive = true
  value     = var.service_account_content.pub_key == "" ? module.master.service_account_pub_key : var.service_account_content.pub_key
}
