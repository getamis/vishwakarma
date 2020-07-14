module "ignition_iam_auth" {
  source = "../../ignitions/aws-iam-auth"

  auth_ca_cert        = module.iam_auth_ca.cert_pem
  auth_cert           = module.iam_auth_cert.cert_pem
  auth_cert_key       = module.iam_auth_cert.private_key_pem
  kubeconfig_dir_path = var.webhook_kubeconfig_dir_path
}
