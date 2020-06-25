data "aws_caller_identity" "current" {}

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