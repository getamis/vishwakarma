data "aws_iam_role" "external" {
  count = "${var.role_arn == "" ? 0 : 1}"
  arn   = "${var.role_arn}"
}

data "aws_iam_policy_document" "default" {
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
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_instance_profile" "etcd" {
  name = "${var.name}-etcd"

  role = "${var.role_arn == "" ?
    join("|", aws_iam_role.etcd.*.name) :
    join("|", data.aws_iam_role.external.*.name)
  }"
}

resource "aws_iam_policy" "etcd" {
  count       = "${var.role_arn == "" ? 1 : 0}"
  name        = "${var.name}-etcd"
  path        = "/"
  description = "policy for kubernetes etcds"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action" : [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket}/*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "etcd" {
  policy_arn = "${aws_iam_policy.etcd.arn}"
  role       = "${aws_iam_role.etcd.name}"
}
