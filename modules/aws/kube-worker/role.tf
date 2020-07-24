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
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_instance_profile" "worker" {
  name_prefix = "${var.name}-worker-${local.instance_config["name"]}-"
  role        = var.role_name == "" ? join("|", aws_iam_role.worker.*.name) : var.role_name
}

resource "aws_iam_policy" "worker" {
  count       = var.role_name == "" ? 1 : 0
  name_prefix = "${var.name}-worker-${local.instance_config["name"]}-"
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

resource "aws_iam_policy" "worker_vpc_cni" {
  count       = var.network_plugin == "amazon-vpc" ? 1 : 0
  name_prefix = "${var.name}-worker-${local.instance_config["name"]}-vpc-cni"
  path        = "/"
  description = "Amazon VPC CNI policy for Kubernetes workers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
    },
    {
      "Effect": "Allow",
      "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker" {
  count      = var.role_name == "" ? 1 : 0
  policy_arn = aws_iam_policy.worker[0].arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_vpc_cni" {
  count      = var.network_plugin == "amazon-vpc" ? 1 : 0
  policy_arn = aws_iam_policy.worker_vpc_cni[0].arn
  role       = aws_iam_role.worker.name
}
