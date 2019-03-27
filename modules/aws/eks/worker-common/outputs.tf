output "aws_iam_role_arn" {
  value = "${aws_iam_role.workers.arn}"
}

output "coreos_ami_id" {
  value = "${data.aws_ami.coreos_ami.image_id}"
}

output "workers_profile_arn" {
  value = "${aws_iam_instance_profile.workers.arn}"
}

output "ign_config_rendered" {
  value = "${data.ignition_config.s3.rendered}"
}
