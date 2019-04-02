locals {
  cluster_name = "${var.phase}-${var.project}"
}


resource "aws_eks_cluster" "vishwakarma" {
  name     = "${var.phase}-${var.project}"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    endpoint_private_access = "${var.endpoint_private_access}"
    endpoint_public_access  =  "${var.endpoint_public_access}"
    subnet_ids              = ["${var.exist_subnet_ids}"]
    security_group_ids      = ["${aws_security_group.eks.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_iam_role_policy_attachment.eks_service",
  ]
}
