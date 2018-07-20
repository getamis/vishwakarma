resource "aws_s3_bucket" "ignition" {
  bucket = "${var.name}-${md5(aws_route53_zone.private.zone_id)}"
  acl    = "private"

  tags = "${merge(map(
      "Name", "${var.name}-${md5(aws_route53_zone.private.zone_id)}",
      "kubernetes.io/cluster/${var.name}", "owned",
    ), var.extra_tags)}"
}
