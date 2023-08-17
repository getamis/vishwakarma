data "aws_iam_policy_document" "master_profile" {
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
  assume_role_policy = data.aws_iam_policy_document.master_profile.json
}

resource "aws_iam_instance_profile" "master" {
  name_prefix = "${var.name}-master-"

  role = var.role_name == "" ? join("|", aws_iam_role.master.*.name) : var.role_name
}

data "aws_iam_policy_document" "master" {
  statement {
    sid = "EC2"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeAvailabilityZones",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeVpcs",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "S3"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]
  }
  statement {
    sid = "ECR"
    actions = [
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
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "master" {
  count       = var.role_name == "" ? 1 : 0
  name        = "${var.name}-master"
  path        = "/"
  description = "policy for kubernetes masters"
  policy      = data.aws_iam_policy_document.master.json
}

data "aws_iam_policy_document" "master_vpc_cni" {
  statement {
    sid = "EC2General"
    actions = [
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
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "EC2Specific"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }
}

resource "aws_iam_policy" "master_vpc_cni" {
  count       = var.network_plugin == "amazon-vpc" ? 1 : 0
  name        = "${var.name}-master-vpc-cni"
  path        = "/"
  description = "Amazon VPC CNI policy for Kubernetes masters"
  policy      = data.aws_iam_policy_document.master_vpc_cni.json
}

resource "aws_iam_role_policy_attachment" "master" {
  policy_arn = aws_iam_policy.master[0].arn
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "master_vpc_cni" {
  count      = var.network_plugin == "amazon-vpc" ? 1 : 0
  policy_arn = aws_iam_policy.master_vpc_cni[0].arn
  role       = aws_iam_role.master.name
}