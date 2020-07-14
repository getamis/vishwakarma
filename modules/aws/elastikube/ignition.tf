module "kube_iam_auth" {
  source = "../kube-iam-auth"

  name                        = var.name
  ignition_s3_bucket          = aws_s3_bucket.ignition.id
  oidc_s3_bucket              = "${var.name}-${md5("${aws_route53_zone.private.zone_id}-oidc")}"
  webhook_kubeconfig_dir_path = "/etc/kubernetes/config/aws-iam-authenticator"
  extra_tags                  = var.extra_tags
}
