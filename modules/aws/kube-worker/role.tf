data "aws_iam_policy_document" "worker_profile" {
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
  count              = var.role_name == "" ? 1 : 0
  name_prefix        = "${var.name}-worker-${var.instance_config["name"]}-"
  assume_role_policy = data.aws_iam_policy_document.worker_profile.json
}

resource "aws_iam_instance_profile" "worker" {
  name_prefix = "${var.name}-worker-${var.instance_config["name"]}-"
  role        = var.role_name == "" ? join("|", aws_iam_role.worker.*.name) : var.role_name
}

data "aws_iam_policy_document" "worker" {
  statement {
    sid = "EC2"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
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

resource "aws_iam_policy" "worker" {
  count       = var.role_name == "" ? 1 : 0
  name_prefix = "${var.name}-worker-${var.instance_config["name"]}-"
  path        = "/"
  description = "policy for kubernetes workers"
  policy      = data.aws_iam_policy_document.worker.json
}

data "aws_iam_policy_document" "worker_vpc_cni" {
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

resource "aws_iam_policy" "worker_vpc_cni" {
  count       = (var.network_plugin == "amazon-vpc" && var.role_name == "") ? 1 : 0
  name_prefix = "${var.name}-worker-${var.instance_config["name"]}-vpc-cni-"
  path        = "/"
  description = "Amazon VPC CNI policy for Kubernetes workers"
  policy      = data.aws_iam_policy_document.worker_vpc_cni.json
}

resource "aws_iam_role_policy_attachment" "worker" {
  count      = var.role_name == "" ? 1 : 0
  policy_arn = aws_iam_policy.worker[0].arn
  role       = aws_iam_role.worker[0].name
}

resource "aws_iam_role_policy_attachment" "worker_vpc_cni" {
  count      = (var.network_plugin == "amazon-vpc" && var.role_name == "") ? 1 : 0
  policy_arn = aws_iam_policy.worker_vpc_cni[0].arn
  role       = aws_iam_role.worker[0].name
}

data "aws_iam_policy_document" "worker_ccm" {
  statement {
    sid = "CCMWorker"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "worker_ccm" {
  count       = var.role_name == "" ? 1 : 0
  name        = "${var.name}-worker-ccm"
  path        = "/"
  description = "AWS cloud controller policy for Kubernetes workers"
  policy      = data.aws_iam_policy_document.worker_ccm.json
}

resource "aws_iam_role_policy_attachment" "worker_ccm" {
  policy_arn = aws_iam_policy.worker_ccm[0].arn
  role       = aws_iam_role.worker[0].name
}
