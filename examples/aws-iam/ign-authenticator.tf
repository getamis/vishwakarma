module "ignition_aws_iam_authenticator" {
  source = "../../modules/ignitions/aws-iam-auth-master"

  webhook_kubeconfig_ca   = module.kubernetes.certificate_authority
  webhook_kubeconfig_path = var.auth_webhook_path
}

data "aws_s3_bucket" "kubernetes" {
  bucket = module.kubernetes.s3_bucket
}

data "template_file" "kubeconfig_iam" {

  template = file("${path.module}/resources/kubeconfig.iam")

  vars = {
    api_server_endpoint = module.kubernetes.endpoint
    cluster_name        = local.cluster_name
    cluster_ca          = module.kubernetes.certificate_authority
  }
}

resource "aws_s3_bucket_object" "kubeconfig_iam" {
  bucket = data.aws_s3_bucket.kubernetes.id

  key     = "kubeconfig.iam"
  content = data.template_file.kubeconfig_iam.rendered
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "kubeconfig.iam",
    "kubernetes.io/cluster/${local.cluster_name}", "owned",
  ), var.extra_tags)
}
