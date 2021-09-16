output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "ignition_s3_bucket" {
  value = module.master.ignition_s3_bucket
}

output "oidc_s3_bucket" {
  value = module.irsa.oidc_s3_bucket
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA."
  value       = module.irsa.oidc_provider_arn
}

output "oidc_issuer" {
  description = "Issuer of OIDC provider for IRSA."
  value       = module.irsa.oidc_issuer
}