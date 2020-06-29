data "aws_s3_bucket_object" "pod_identity_webhook_crt" {
  bucket = var.ignition_s3_bucket
  key    = "pod-identity-webhook.crt"
}

resource "local_file" "pod_identity_webhook_crt" {
    content     = data.aws_s3_bucket_object.pod_identity_webhook_crt.body
    filename = "deploy/secrets/tls.crt"
}

data "aws_s3_bucket_object" "pod_identity_webhook_key" {
  bucket = var.ignition_s3_bucket
  key    = "pod-identity-webhook.key"
}

resource "local_file" "pod_identity_webhook_key" {
    content     = data.aws_s3_bucket_object.pod_identity_webhook_key.body
    filename = "deploy/secrets/tls.key"
}

data "aws_s3_bucket_object" "oidc_issuer_pub" {
  bucket = var.ignition_s3_bucket
  key    = "oidc-issuer.pub"
}

resource "local_file" "oidc_issuer_pub" {
    content     = data.aws_s3_bucket_object.oidc_issuer_pub.body
    filename = "deploy/secrets/oidc-issuer.pub"
}