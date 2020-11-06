data "aws_iam_policy_document" "etcd_profile" {
  statement {
    sid = "KubeEtcdAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "etcd" {
  name_prefix        = "${var.name}-etcd-"
  assume_role_policy = data.aws_iam_policy_document.etcd_profile.json
}

resource "aws_iam_instance_profile" "etcd" {
  name = "${var.name}-etcd"
  role = aws_iam_role.etcd.name
}

data "aws_iam_policy_document" "etcd" {
  statement {
    sid     = "S3"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "etcd" {
  name        = "${var.name}-etcd"
  path        = "/"
  description = "policy for kubernetes etcds"
  policy      = data.aws_iam_policy_document.etcd.json 
}

resource "aws_iam_role_policy_attachment" "etcd" {
  policy_arn = aws_iam_policy.etcd.arn
  role       = aws_iam_role.etcd.name
}
