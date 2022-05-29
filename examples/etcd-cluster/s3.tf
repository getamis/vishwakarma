resource "aws_s3_bucket" "ignition" {
  bucket = "${module.label.id}-${md5(aws_route53_zone.private.zone_id)}"

  tags = merge(module.label.tags, map(
    "Name", "${module.label.id}-${md5(aws_route53_zone.private.zone_id)}",
    "Role", "etcd"
  ))
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
