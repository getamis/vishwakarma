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
  name_prefix = "${var.name}-worker-${var.worker_config["name"]}-"
  role        = "${var.role_name == "" ? join("|", aws_iam_role.worker.*.name) : var.role_name}"
}

resource "aws_iam_policy" "worker" {
  count       = "${var.role_name == "" ? 1 : 0}"
  name        = "${var.name}-worker-${var.worker_config["name"]}"
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
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket}*",
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
  count      = "${var.role_name == "" ? 1 : 0}"
  policy_arn = "${aws_iam_policy.worker.arn}"
  role       = "${aws_iam_role.worker.name}"
}
