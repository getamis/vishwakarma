output "eks_id" {
  value = "${aws_eks_cluster.eks.id}"
}

output "eks_endpoint" {
  value = "${aws_eks_cluster.eks.endpoint}"
}

output "eks_version" {
  value = "${aws_eks_cluster.eks.version}"
}

output "eks_certificate_authority" {
  value = "${aws_eks_cluster.eks.certificate_authority}"
}
