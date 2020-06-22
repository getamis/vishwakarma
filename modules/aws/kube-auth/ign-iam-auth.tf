module "ignition_aws_iam_authenticator" {
  source = "../../ignitions/aws-iam-auth"

  webhook_kubeconfig_ca   = var.webhook_kubeconfig_ca
  webhook_kubeconfig_path = var.webhook_kubeconfig_path
}