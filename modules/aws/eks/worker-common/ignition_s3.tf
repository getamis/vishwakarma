resource "aws_s3_bucket_object" "ignition_worker" {
  bucket  = "${var.s3_bucket}"
  key     = "ignition_${var.worker_name}.json"
  content = "${data.ignition_config.main.rendered}"
  acl     = "private"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "${var.cluster_name}-ignition-${var.worker_name}",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

data "ignition_config" "s3" {
  replace {
    source       = "${format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition_worker.key)}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
