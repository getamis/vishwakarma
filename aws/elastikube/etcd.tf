module "etcd" {
  source = "../../aws/kube-etcd"

  name       = "${var.name}"
  aws_region = "${var.aws_region}"

  ssh_key     = "${var.ssh_key}"
  etcd_config = "${var.etcd_config}"

  subnet_ids               = ["${var.subnet_ids}"]
  master_security_group_id = "${aws_security_group.master.id}"
  zone_id                  = "${aws_route53_zone.private.zone_id}"
  s3_bucket                = "${aws_s3_bucket.ignition.id}"
  reboot_strategy          = "${var.reboot_strategy}"

  extra_ignition_file_ids         = ["${var.extra_etcd_ignition_file_ids}"]
  extra_ignition_systemd_unit_ids = ["${var.extra_etcd_ignition_systemd_unit_ids}"]
  extra_tags                      = "${var.extra_tags}"
}
