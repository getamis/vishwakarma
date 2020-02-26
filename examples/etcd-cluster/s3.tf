resource "aws_s3_bucket" "ignition" {
  bucket = "${local.cluster_name}-${md5(aws_route53_zone.private.zone_id)}"
  acl    = "private"

  tags = merge(map(
    "Name", "${local.cluster_name}-${md5(aws_route53_zone.private.zone_id)}",
    "kubernetes.io/cluster/${local.cluster_name}", "owned",
  ), var.extra_tags)
}

resource "aws_s3_bucket_public_access_block" "ignition" {
  bucket = aws_s3_bucket.ignition.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
