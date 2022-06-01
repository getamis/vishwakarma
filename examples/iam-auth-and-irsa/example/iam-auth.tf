locals {
  iam_kubeconfig_vars = {
    api_server_endpoint = local.kubernetes_host
    cluster_name        = module.label.id
    cluster_ca          = local.kubernetes_cluster_ca
    user                = "kubernetes-admin"
    context             = "kubernetes-admin@kubernetes-iam"
    k8s_admin_iam_role  = aws_iam_role.k8s_admin.arn
  }
}

data "aws_iam_policy_document" "k8s_assume_role" {
  statement {
    sid = "AssumeRole"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "k8s_admin" {
  name               = "${local.kubernetes_name}-admin"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.k8s_assume_role.json
}

resource "local_file" "iam_admin_yaml" {
  filename = "./deploy/iam-admin.yaml"
  content = templatefile("${path.module}/templates/iam-admin.yaml.tpl", {
    user               = "kubernetes-admin"
    k8s_admin_iam_role = aws_iam_role.k8s_admin.arn
  })
}

resource "null_resource" "apply_iam_admin_mapping" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./deploy"

    environment = {
      KUBECONFIG = "./.secret/kubeconfig"
    }
  }

  triggers = {
    controller_primary = timestamp()
  }

  depends_on = [local_file.iam_admin_yaml, local_file.kubeconfig]
}

resource "aws_s3_object" "kubeconfig_iam" {
  bucket = var.ignition_s3_bucket

  key     = "kubeconfig-iam.conf"
  content = templatefile("${path.module}/templates/kubeconfig.iam.tpl", local.iam_kubeconfig_vars)

  acl                    = "private"
  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(module.label.tags, {
    "Name" = "kubeconfig.iam"
    "Role" = "k8s-master"
  })
}

resource "local_file" "kubeconfig_iam_local" {
  filename = "./kubeconfig/kubeconfig-iam.conf"
  content  = templatefile("${path.module}/templates/kubeconfig.iam.tpl", local.iam_kubeconfig_vars)
}
