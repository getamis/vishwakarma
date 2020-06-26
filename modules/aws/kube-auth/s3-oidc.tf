data "aws_region" "current" {}

resource "aws_s3_bucket" "oidc" {
  bucket = var.oidc_s3_bucket
  acl    = "public-read"

  tags = merge(map(
  "Name", "${var.name}-oidc-${md5("${var.name}-oidc")}"), var.extra_tags)
}

resource "aws_s3_bucket_object" "pod_identity_webhook_crt" {
  bucket = var.ignition_s3_bucket

  key     = "pod-identity-webhook.crt"
  content = module.pod_identity_webhook_cert.cert_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "pod-identity-webhook.crt",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "pod_identity_webhook_prikey" {
  bucket = var.ignition_s3_bucket

  key     = "pod-identity-webhook.key"
  content = module.pod_identity_webhook_cert.private_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "pod-identity-webhook.key",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "oidc_issuer_pubkey" {
  bucket = var.ignition_s3_bucket

  key     = "oidc-issuer.pub"
  content = var.oidc_issuer_pubkey
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(var.extra_tags, map(
    "Name", "oidc-issuer.pub",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "k8s-master"
  ))
}
