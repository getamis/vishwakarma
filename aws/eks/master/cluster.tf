resource "aws_eks_cluster" "eks" {
  name     = "${var.phase}-${var.project}"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    subnet_ids = ["${var.exist_subnet_ids}"]
    security_group_ids = ["${aws_security_group.eks.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_iam_role_policy_attachment.eks_service",
  ]
}
