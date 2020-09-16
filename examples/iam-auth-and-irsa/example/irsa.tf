resource "aws_iam_role" "s3_echoer" {
  name               = "s3-echoer"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_issuer}:sub": "system:serviceaccount:default:s3-echoer"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_echoer" {
  role       = aws_iam_role.s3_echoer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "local_file" "s3_echoer" {
  filename = "./deploy/s3-echoer.yaml"
  content = templatefile("${path.module}/templates/s3-echoer.yaml.tpl", {
    account_id = data.aws_caller_identity.current.account_id
  })
}

resource "null_resource" "apply_s3_echoer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./deploy"
    environment = {
      KUBECONFIG = "./.secret/kubeconfig"
    }
  }
  depends_on = [local_file.s3_echoer, local_file.kubeconfig]
}
