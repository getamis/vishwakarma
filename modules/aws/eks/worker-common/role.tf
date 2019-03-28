data "aws_iam_policy_document" "workers_assume_role_policy" {
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

data "aws_iam_role" "workers" {
  count = "${var.worker_iam_role == "" ? 0 : 1}"
  name  = "${var.worker_iam_role}"
}

resource "aws_iam_role" "workers" {
  name_prefix        = "${var.cluster_name}-${var.worker_name}-"
  assume_role_policy = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
}

resource "aws_iam_instance_profile" "workers" {
  name = "${var.cluster_name}-${var.worker_name}"

  role = "${var.worker_iam_role == "" ?
    join("|", aws_iam_role.workers.*.name) :
    join("|", data.aws_iam_role.workers.*.name)
  }"
}

resource "aws_iam_policy" "workers" {
  count       = "${var.worker_iam_role == "" ? 1 : 0}"
  name        = "${var.cluster_name}-${var.worker_name}"
  path        = "/"
  description = "policy for k8s workers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action" : [
        "s3:GetObject"
      ],
      "Resource": "arn:${local.arn}:s3:::*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "workers" {
  policy_arn = "${aws_iam_policy.workers.arn}"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}
