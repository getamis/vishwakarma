output "id" {
  value = "${aws_eks_cluster.eks.id}"
}

output "endpoint" {
  value = "${aws_eks_cluster.eks.endpoint}"
}

output "version" {
  value = "${aws_eks_cluster.eks.version}"
}

output "certificate_authority_data" {
  value = "${aws_eks_cluster.eks.certificate_authority.0.data}"
}

output "worker_sg_id" {
  value = "${aws_security_group.workers.id}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.vishwakarma.bucket}"
}
