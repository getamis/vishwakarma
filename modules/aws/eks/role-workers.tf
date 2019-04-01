resource "aws_iam_role" "workers" {
  count       = "${length(var.worker_groups)}"
  name                  = "${var.phase}-${var.project}-worker-${var.worker_groups[count.index]}"
  assume_role_policy    = "${data.aws_iam_policy_document.workers_assume_role.json}"
  permissions_boundary  = "${var.permissions_boundary}"
  path                  = "${var.iam_path}"
  force_detach_policies = true
}

resource "aws_iam_instance_profile" "workers" {
  count       = "${length(var.worker_groups)}"
  name        = "${var.phase}-${var.project}-worker-${var.worker_groups[count.index]}"
  role        = "${aws_iam_role.workers.*.name[count.index]}"
  path        = "${var.iam_path}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count      = "${length(var.worker_groups)}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.*.name[count.index]}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count      = "${length(var.worker_groups)}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.*.name[count.index]}"
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "${var.phase}-${var.project}-worker-autoscaling-"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.vishwakarma.id}"
  policy      = "${data.aws_iam_policy_document.worker_autoscaling.json}"
  path        = "${var.iam_path}"
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  count      = "${length(var.worker_groups)}"
  policy_arn = "${aws_iam_policy.worker_autoscaling.arn}"
  role       = "${aws_iam_role.workers.*.name[count.index]}"
}

resource "aws_iam_policy" "worker_ignition" {
  name_prefix = "${var.phase}-${var.project}-worker-ignition-"
  description = "EKS worker node to get the ignition file from s3"
  policy      = "${data.aws_iam_policy_document.worker_ignition.json}"
  path        = "${var.iam_path}"
}

resource "aws_iam_role_policy_attachment" "worker_ignition" {
  count      = "${length(var.worker_groups)}"
  policy_arn = "${aws_iam_policy.worker_ignition.arn}"
  role       = "${aws_iam_role.workers.*.name[count.index]}"
}

data "aws_iam_policy_document" "workers_assume_role" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.vishwakarma.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}



data "aws_iam_policy_document" "worker_ignition" {
  statement {
    sid    = "eksWorkerIgnition"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = ["arn:aws:s3:::${aws_s3_bucket.eks.id}/*"]
  }
}

