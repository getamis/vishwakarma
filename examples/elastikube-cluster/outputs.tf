output "bastion_public_ip" {
  value = "${module.network.bastion_public_ip}"
}

output "ignition_s3_bucket" {
  value = "${module.kubernetes.s3_bucket}"
}
