output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "ignition_s3_bucket" {
  value = module.master.ignition_s3_bucket
}