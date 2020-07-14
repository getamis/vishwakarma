output "id" {
  value       = var.name
  description = "Kubernetes cluster name."
}

output "endpoint" {
  value       = module.master.endpoint
  description = "Kubernetes cluster endpoint."
}

output "kubernetes_version" {
  value       = var.kubernetes_version
  description = "Kubernetes cluster version."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "The VPC id used by K8S"
}

output "ignition_s3_bucket" {
  value       = aws_s3_bucket.ignition.id
  description = "The S3 bucket for storing provision ignition file"
}

output "oidc_s3_bucket" {
  value       = module.kube_auth.oidc_s3_bucket
  description = "The S3 bucket for storing oidc data"
}

output "master_sg_ids" {
  value       = [module.master.master_sg_id]
  description = "The security group which used by K8S master"
}

output "worker_sg_ids" {
  value       = [aws_security_group.workers.id]
  description = "The security gruop for worker group"
}

output "master_role_name" {
  value = module.master.default_role_name
}

output "etcd_role_name" {
  value = module.etcd.default_role_name
}

output "kubernetes_ca_cert" {
  description = "Kubernetes root CA Cert"
  value       = module.master.kubernetes_ca_cert
}

output "tls_bootstrap_token_id" {
  value = module.master.tls_bootstrap_token_id
}

output "tls_bootstrap_token_secret" {
  value = module.master.tls_bootstrap_token_secret
}