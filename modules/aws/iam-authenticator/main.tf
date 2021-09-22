module "ignition_iam_auth" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-kubernetes//modules/extra-addons/aws-iam-authenticator?ref=v1.4.6"

  cluster_name        = var.name
  container           = var.container
  addons_dir_path     = var.kube_addons_dir_path
  kubeconfig_dir_path = var.webhook_kubeconfig_dir_path
  server_port         = var.webhook_server_port
  pki_dir_path        = var.pki_dir_path
  auth_ca_cert        = module.iam_auth_ca.cert_pem
  auth_cert           = module.iam_auth_cert.cert_pem
  auth_cert_key       = module.iam_auth_cert.private_key_pem
}
