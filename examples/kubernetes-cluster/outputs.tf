output "bastion_public_ip" {
  value = module.network.bastion_public_ip
}

output "ignition_s3_bucket" {
  value = module.master.ignition_s3_bucket
}

output "oidc_s3_bucket" {
  value = module.master.oidc_s3_bucket
}