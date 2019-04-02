output "id" {
  value = "${aws_eks_cluster.vishwakarma.id}"
}

output "endpoint" {
  value = "${aws_eks_cluster.vishwakarma.endpoint}"
}

output "kubernetes_version" {
  value = "${aws_eks_cluster.vishwakarma.version}"
}

output "worker_sg_id" {
  value = "${aws_security_group.worker.id}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.eks.bucket}"
}

output "worker_role_arns" {
  value = "${aws_iam_role.workers.*.name}"
}

output "worker_instance_profiles" {
  value = "${aws_iam_instance_profile.workers.*.name}"
}

