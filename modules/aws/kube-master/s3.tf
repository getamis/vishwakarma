resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = var.s3_bucket
  key     = "kubeconfig"
  content = module.ignition_kube_config.content
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "kubeconfig",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}
