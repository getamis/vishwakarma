module "ignition_aws_iam_authenticator" {
  source = "../../ignitions/aws-iam-authenticator"

  webhook_kubeconfig_ca   = "${module.kubernetes.certificate_authority}"
  webhook_kubeconfig_path = "${var.auth_webhook_path}"
}
