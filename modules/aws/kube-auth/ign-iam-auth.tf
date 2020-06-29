module "ignition_aws_iam_auth" {
  source = "../../ignitions/aws-iam-auth"

  aws_iam_auth_ca         = module.aws_iam_auth_root_ca.cert_pem
  aws_iam_auth_crt_pem    = module.aws_iam_auth_cert.cert_pem
  aws_iam_auth_key_pem    = module.aws_iam_auth_cert.private_key_pem
  webhook_kubeconfig_path = var.webhook_kubeconfig_path
}