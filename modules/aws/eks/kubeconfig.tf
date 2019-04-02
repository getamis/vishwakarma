resource "aws_s3_bucket" "eks" {
  # Buckets must start with a lower case name and are limited to 63 characters,
  # so we prepend the letter 'a' and use the md5 hex digest for the case of a long domain
  # leaving 29 chars for the cluster name.
  bucket = "${ format("%s%s-%s", "a", aws_eks_cluster.vishwakarma.id, md5(format("%s-%s", var.aws_region , aws_eks_cluster.vishwakarma.endpoint))) }"


  acl = "private"

  tags = "${merge(map(
      "Name", "${ format("%s%s-%s", "a", aws_eks_cluster.vishwakarma.id, md5(format("%s-%s", var.aws_region , aws_eks_cluster.vishwakarma.endpoint))) }",
      "KubernetesCluster", "${aws_eks_cluster.vishwakarma.id}",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "aws_s3_bucket_public_access_block" "eks" {
  bucket = "${aws_s3_bucket.eks.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "ignition_kubeconfig" {
  source                     = "../../ignitions/eks-kube-config"
  cluster_name               = "${aws_eks_cluster.vishwakarma.id}" 
  cluster_endpoint           = "${aws_eks_cluster.vishwakarma.endpoint}"
  certificate_authority_data = "${aws_eks_cluster.vishwakarma.certificate_authority.0.data}"
}

resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = "${aws_s3_bucket.eks.bucket}"
  key     = "kubeconfig"
  content = "${module.ignition_kubeconfig.rendered}"
  acl     = "private"

  # The current Vishwakarma installer stores bits of the kubeconfig in KMS. As we
  # do not support KMS yet, we at least offload it to S3 for now. Eventually,
  # we should consider using KMS-based client-side encryption, or uploading it
  # to KMS.
  server_side_encryption = "AES256"
  content_type = "text/plain"

  tags = "${merge(map(
      "Name", "kubeconfig",
      "KubernetesCluster", "${aws_eks_cluster.vishwakarma.id}",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "local_file" "kubeconfig" {
    count    = "${var.kubeconfig_output_flag ? 1 : 0}"
    content  = "${module.ignition_kubeconfig.rendered}"
    filename = "${var.config_output_path}/kubeconfig"
}
