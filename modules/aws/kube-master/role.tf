data "aws_iam_policy_document" "default" {
  statement {
    sid = "KubeMasterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "master" {
  name_prefix        = "${var.name}-master-"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_instance_profile" "master" {
  name_prefix = "${var.name}-master-"

  role = "${var.role_name == "" ?
    join("|", aws_iam_role.master.*.name) :
    var.role_name
  }"
}

resource "aws_iam_policy" "master" {
  count       = "${var.role_name == "" ? 1 : 0}"
  name        = "${var.name}-master"
  path        = "/"
  description = "policy for kubernetes masters"

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
      "Resource": "arn:aws:s3:::${var.s3_bucket}/*",
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

resource "aws_iam_role_policy_attachment" "master" {
  policy_arn = "${aws_iam_policy.master.arn}"
  role       = "${aws_iam_role.master.name}"
}
