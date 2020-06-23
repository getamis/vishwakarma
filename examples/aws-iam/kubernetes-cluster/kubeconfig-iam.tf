data "template_file" "kubeconfig_iam" {

  template = file("${path.module}/resources/kubeconfig.iam")

  vars = {
    api_server_endpoint = module.master.endpoint
    cluster_name        = local.cluster_name
    cluster_ca          = module.master.certificate_authority
  }
}

resource "aws_s3_bucket_object" "kubeconfig_iam" {
  bucket = module.master.ignition_s3_bucket

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