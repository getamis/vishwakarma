output "oidc_issuer_endpoint" {
  value = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"
}