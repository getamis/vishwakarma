output "id" {
  value       = aws_eks_cluster.vishwakarma.id
  description = "the eks cluster name"
}

output "endpoint" {
  value       = aws_eks_cluster.vishwakarma.endpoint
  description = "the eks cluster endpoint"
}

output "kubernetes_version" {
  value       = aws_eks_cluster.vishwakarma.version
  description = "the eks cluster version"
}

output "worker_sg_id" {
  value       = aws_security_group.worker.id
  description = "the security group id for worker group"
}

output "s3_bucket" {
  value       = aws_s3_bucket.eks.bucket
  description = "the s3 bucket where put kubeconfig"
}

output "worker_role_arns" {
  value       = aws_iam_role.workers.*.name
  description = "the role arns for worker groups"
}

output "worker_instance_profiles" {
  value       = aws_iam_instance_profile.workers.*.name
  description = "the instance profiles name for worker groups"
}

