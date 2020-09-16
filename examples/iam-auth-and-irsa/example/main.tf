module "label" {
  source      = "../../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket_object" "kubeconfig" {
  bucket = var.ignition_s3_bucket
  key    = var.kubeconfig_s3_key
}

resource "local_file" "kubeconfig" {
  filename   = "./.secret/kubeconfig"
  content    = data.aws_s3_bucket_object.kubeconfig.body
  depends_on = [data.aws_s3_bucket_object.kubeconfig]
}

locals {
  kubernetes_name       = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["name"]
  kubernetes_host       = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["cluster"]["server"]
  kubernetes_cluster_ca = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["cluster"]["certificate-authority-data"]
}