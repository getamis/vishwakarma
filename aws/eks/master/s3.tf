resource "aws_s3_bucket" "vishwakarma" {
  # Buckets must start with a lower case name and are limited to 63 characters,
  # so we prepend the letter 'a' and use the md5 hex digest for the case of a long domain
  # leaving 29 chars for the cluster name.
  bucket = "${ format("%s%s-%s", "a", aws_eks_cluster.eks.id, md5(format("%s-%s", var.aws_region , aws_eks_cluster.eks.endpoint))) }"


  acl = "private"

  tags = "${merge(map(
      "Name", "${aws_eks_cluster.eks.id}-vishwakarma",
      "KubernetesCluster", "${aws_eks_cluster.eks.id}",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"

}

# kubeconfig
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    cluster_name          = "${aws_eks_cluster.eks.id}"
    cluster_endpoint      = "${aws_eks_cluster.eks.endpoint}"
    certificate_authority_data = "${aws_eks_cluster.eks.certificate_authority.0.data}"
  }
}

resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = "${aws_s3_bucket.vishwakarma.bucket}"
  key     = "kubeconfig"
  content = "${data.template_file.kubeconfig.rendered}"
  acl     = "private"

  # The current Vishwakarma installer stores bits of the kubeconfig in KMS. As we
  # do not support KMS yet, we at least offload it to S3 for now. Eventually,
  # we should consider using KMS-based client-side encryption, or uploading it
  # to KMS.
  server_side_encryption = "AES256"
  content_type = "text/plain"

  tags = "${merge(map(
      "Name", "${aws_eks_cluster.eks.id}-kubeconfig",
      "KubernetesCluster", "${aws_eks_cluster.eks.id}",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "local_file" "kubeconfig" {
    content     = "${data.template_file.kubeconfig.rendered}"
    filename = "${var.config_output_path}/kubeconfig"
}
