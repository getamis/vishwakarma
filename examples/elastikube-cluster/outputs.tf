output "bastion_public_ip" {
  value = module.network.bastion_public_ip
}

output "ignition_s3_bucket" {
  value = module.master.s3_bucket
}
