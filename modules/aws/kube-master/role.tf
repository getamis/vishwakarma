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
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_instance_profile" "master" {
  name_prefix = "${var.name}-master-"

  role = var.role_name == "" ? join("|", aws_iam_role.master.*.name) : var.role_name
}

resource "aws_iam_policy" "master" {
  count       = var.role_name == "" ? 1 : 0
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:AttachNetworkInterface",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeTags",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
         "ec2:CreateTags"
       ],
       "Resource": ["arn:aws:ec2:*:*:network-interface/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "master" {
  policy_arn = aws_iam_policy.master[0].arn
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.master.name
}
