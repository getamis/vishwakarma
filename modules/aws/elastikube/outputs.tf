output "id" {
  value       = var.name
  description = "K8S cluster name"
}

output "certificate_authority" {
  value       = module.master.certificate_authority
  description = "K8S root CA Cert"
}

output "endpoint" {
  value       = module.master.endpoint
  description = "K8S cluster endpoint"
}

output "version" {
  value       = var.hyperkube_container["image_tag"]
  description = "K8S cluster version"
}

output "vpc_id" {
  value       = local.vpc_id
  description = "The VPC id used by K8S"
}

output "s3_bucket" {
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

output oidc_issuer_pubkey {
  value = module.master.oidc_issuer_pubkey
}

output "master_role_name" {
  value = module.master.default_role_name
}

output "etcd_role_name" {
  value = module.etcd.default_role_name
}