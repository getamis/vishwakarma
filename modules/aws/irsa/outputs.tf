output "oidc_s3_bucket" {
  value = aws_s3_bucket.oidc.id
}

output "oidc_api_audiences" {
  value = var.oidc_api_audiences
}

output "oidc_issuer" {
  description = "Domain name of the S3 bucket (*.s3.amazonaws.com)."
  value       = "s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.irsa.arn
}

output "ignitions_files" {
  value = module.ignition_pod_idenity_webhook.files
}