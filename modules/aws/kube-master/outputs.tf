output "master_internal_elb_name" {
  value = aws_elb.master_internal.name
}

output "endpoint" {
  value = "https://${aws_elb.master_internal.dns_name}"
}

output "master_asg_name" {
  value = aws_autoscaling_group.master.name
}

output "master_launch_template_name" {
  value = aws_launch_template.master.name
}

output "master_sg_id" {
  value = local.master_sg_id
}

output "default_role_name" {
  value = aws_iam_role.master.name
}

output "kubernetes_ca_cert" {
  sensitive = true
  value     = module.kubernetes_ca.cert_pem
}

output "service_account_pub_key" {
  sensitive = true
  value     = var.service_account_content.pub_key == "" ? module.service_account.public_key_pem : var.service_account_content.pub_key
}

output "tls_bootstrap_token_id" {
  sensitive = true
  value     = random_id.bootstrap_token_id.hex
}

output "tls_bootstrap_token_secret" {
  sensitive = true
  value     = random_id.bootstrap_token_secret.hex
}
