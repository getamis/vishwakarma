output "id" {
  value = "${var.name}"
}

output "certificate_authority" {
  value = "${module.master.certificate_authority}"
}

output "endpoint" {
  value = "${module.master.endpoint}"
}

output "version" {
  value = "${var.version}"
}

output "vpc_id" {
  value = "${local.vpc_id}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.ignition.id}"
}

output "master_sg_ids" {
  value = ["${module.master.master_sg_id}"]
}

output "worker_sg_ids" {
  value = ["${aws_security_group.workers.id}"]
}
