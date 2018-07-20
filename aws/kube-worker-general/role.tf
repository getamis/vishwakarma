data "aws_iam_role" "external" {
  count = "${var.role_arn == "" ? 0 : 1}"
  arn   = "${var.role_arn}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "KubeWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name_prefix        = "${var.name}-worker-"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.name}-worker"

  role = "${var.role_arn == "" ?
    join("|", aws_iam_role.worker.*.name) :
    join("|", data.aws_iam_role.external.*.name)
  }"
}

resource "aws_iam_policy" "worker" {
  count       = "${var.role_arn == "" ? 1 : 0}"
  name        = "${var.name}-worker"
  path        = "/"
  description = "policy for kubernetes workers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": "arn:${local.arn}:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker" {
  policy_arn = "${aws_iam_policy.worker.arn}"
  role       = "${aws_iam_role.worker.name}"
}
