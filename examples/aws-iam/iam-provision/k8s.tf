data "template_file" "iam_auth_yaml" {
  template = file("${path.module}/resources/iam-auth.yaml")

  vars = {
    image        = var.aws_iam_authenticator_image
    cluster_name = local.kubernetes_name
  }
}

data "template_file" "iam_admin_yaml" {
  template = file("${path.module}/resources/iam-admin.yaml")

  vars = {
    cluster_name       = local.kubernetes_name
    k8s_admin_iam_role = aws_iam_role.k8s_admin.arn
  }
}

resource "local_file" "iam_auth_yaml" {
  content  = data.template_file.iam_auth_yaml.rendered
  filename = "./deploy/kubernetes/iam-auth.yaml"
}

resource "local_file" "iam_admin_yaml" {
  content  = data.template_file.iam_admin_yaml.rendered
  filename = "./deploy/kubernetes/iam-admin.yaml"
}

data "template_file" "irsa_yaml" {
  template = file("${path.module}/resources/irsa.yaml")

  vars = {
    image     = var.pod_identity_webhook_image
    ca_bundle = base64encode(data.aws_s3_bucket_object.pod_identity_webhook_crt.body)
  }
}

resource "local_file" "irsa_yaml" {
  content  = data.template_file.irsa_yaml.rendered
  filename = "./deploy/kubernetes/irsa.yaml"
}

data "aws_s3_bucket_object" "kubeconfig" {
  bucket = var.ignition_s3_bucket
  key    = var.kubeconfig_s3_key
}

locals {
  kubernetes_name       = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["name"]
  kubernetes_host       = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["cluster"]["server"]
  kubernetes_cluster_ca = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)["clusters"][0]["cluster"]["certificate-authority-data"]
}

data "template_file" "kubeconfig_iam" {

  template = file("${path.module}/resources/kubeconfig.iam")

  vars = {
    api_server_endpoint = local.kubernetes_host
    cluster_name        = local.kubernetes_name
    cluster_ca          = local.kubernetes_cluster_ca
    k8s_admin_iam_role  = aws_iam_role.k8s_admin.arn
  }
}

resource "aws_s3_bucket_object" "kubeconfig_iam" {
  bucket = var.ignition_s3_bucket

  key     = "kubeconfig.iam"
  content = data.template_file.kubeconfig_iam.rendered
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(module.label.tags, map(
    "Name", "kubeconfig.iam",
    "Role", "k8s-master"
  ))
}

resource "local_file" "kubeconfig_iam" {
  content  = data.template_file.kubeconfig_iam.rendered
  filename = "./deploy/kubernetes/kubeconfig.iam"
}