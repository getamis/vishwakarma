data "aws_iam_policy_document" "s3_echoer_policy" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["${var.oidc_provider_arn}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer}:sub"
      values   = ["system:serviceaccount:default:s3-echoer"]
    }
  }
}

resource "aws_iam_role" "s3_echoer" {
  name_prefix        = "s3-echoer-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.s3_echoer_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_echoer" {
  role       = aws_iam_role.s3_echoer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "local_file" "s3_echoer" {
  filename = "./deploy/s3-echoer.yaml"
  content = templatefile("${path.module}/templates/s3-echoer.yaml.tpl", {
    role_arn = aws_iam_role.s3_echoer.arn
  })
}

resource "null_resource" "apply_s3_echoer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./deploy"
    environment = {
      KUBECONFIG = "./.secret/kubeconfig"
    }
  }

  triggers = {
    controller_primary = timestamp()
  }

  depends_on = [local_file.s3_echoer, local_file.kubeconfig]
}
