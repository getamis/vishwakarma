data "aws_region" "current" {}

resource "aws_s3_bucket" "oidc" {
  bucket = "${var.name}-oidc-${md5("${var.name}-oidc")}"
  acl    = "public-read"

  tags = merge(map(
  "Name", "${var.name}-oidc-${md5("${var.name}-oidc")}"), var.extra_tags)
}

resource "aws_s3_bucket_object" "pod_identity_webhook_crt" {
  bucket = var.s3_bucket

  key     = "pod_identity_webhook.crt"
  content = module.pod_identity_webhook_cert.cert_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "pod_identity_webhook.crt",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "pod_identity_webhook_prikey" {
  bucket = var.s3_bucket

  key     = "pod_identity_webhook.key"
  content = module.pod_identity_webhook_cert.private_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "pod_identity_webhook.key",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "service_account_pubkey" {
  bucket = var.s3_bucket

  key     = "service_account.pub"
  content = tls_private_key.service_account.public_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "service_account.pub",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "service_account_prikey" {
  bucket = var.s3_bucket

  key     = "service_account.key"
  content = tls_private_key.service_account.private_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "service_account.key",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "oidc_issuer_pubkey" {
  bucket = var.s3_bucket

  key     = "oidc_issuer.pub"
  content = tls_private_key.oidc_issuer.public_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "oidc_issuer.pub",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_object" "oidc_issuer_prikey" {
  bucket = var.s3_bucket

  key     = "oidc_issuer.prikey"
  content = tls_private_key.oidc_issuer.private_key_pem
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "oidc_issuer.prikey",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}