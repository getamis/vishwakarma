resource "aws_s3_bucket" "ignition" {
  bucket = "${module.label.id}-${md5(aws_route53_zone.private.zone_id)}"
  acl    = "private"

  tags = merge(module.label.tags,
    {
      Name = "${module.label.id}-${md5(aws_route53_zone.private.zone_id)}"
      Role = "etcd"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "ignition" {
  bucket = aws_s3_bucket.ignition.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
