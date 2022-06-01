resource "aws_s3_bucket" "ignition" {
  bucket = "${var.name}-${md5(aws_route53_zone.private.zone_id)}"

  tags = merge(var.extra_tags, {
    "Name"                              = "${var.name}-${md5(aws_route53_zone.private.zone_id)}"
    "Role"                              = "k8s-master"
    "kubernetes.io/cluster/${var.name}" = "owned"
  })
}

resource "aws_s3_bucket_acl" "ignition" {
  bucket = aws_s3_bucket.ignition.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "ignition" {
  bucket = aws_s3_bucket.ignition.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
