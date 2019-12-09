data "aws_region" "current" {}

resource "local_file" "kubeconfig" {
  count    = var.kubeconfig_output_flag ? 1 : 0
  content  = data.template_file.kubeconfig.rendered
  filename = "${var.config_output_path}/kubeconfig"
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/resources/kubeconfig.tpl")

  vars = {
    kubeconfig_name           = aws_eks_cluster.vishwakarma.id
    endpoint                  = aws_eks_cluster.vishwakarma.endpoint
    region                    = data.aws_region.current.name
    cluster_auth_base64       = aws_eks_cluster.vishwakarma.certificate_authority.0.data
    aws_authenticator_command = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args = length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_command_args,
      )}" : "        - ${join(
      "\n        - ",
      formatlist("\"%s\"", ["token", "-i", aws_eks_cluster.vishwakarma.id]),
    )}"
    aws_authenticator_additional_args = length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_additional_args,
    )}" : ""
    aws_authenticator_env_variables = length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join(
      "\n",
      data.template_file.aws_authenticator_env_variables.*.rendered,
    )}" : ""
  }
}

data "template_file" "aws_authenticator_env_variables" {
  count = length(var.kubeconfig_aws_authenticator_env_variables)

  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  vars = {
    value = values(var.kubeconfig_aws_authenticator_env_variables)[count.index]
    key   = keys(var.kubeconfig_aws_authenticator_env_variables)[count.index]
  }
}

resource "aws_s3_bucket" "eks" {
  # Buckets must start with a lower case name and are limited to 63 characters,
  # so we prepend the letter 'a' and use the md5 hex digest for the case of a long domain
  # leaving 29 chars for the cluster name.
  bucket = format("%s%s-%s", "a", aws_eks_cluster.vishwakarma.id, md5(format("%s-%s", data.aws_region.current.name, aws_eks_cluster.vishwakarma.endpoint)))


  acl = "private"

  tags = merge(map(
    "Name", format("%s%s-%s", "a", aws_eks_cluster.vishwakarma.id, md5(format("%s-%s", var.aws_region, aws_eks_cluster.vishwakarma.endpoint))),
    "KubernetesCluster", aws_eks_cluster.vishwakarma.id,
    "Phase", var.phase,
    "Project", var.project
  ), var.extra_tags)
}

resource "aws_s3_bucket_public_access_block" "eks" {
  bucket = aws_s3_bucket.eks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = aws_s3_bucket.eks.bucket
  key     = "kubeconfig"
  content = data.template_file.kubeconfig.rendered
  acl     = "private"

  # The current Vishwakarma installer stores bits of the kubeconfig in KMS. As we
  # do not support KMS yet, we at least offload it to S3 for now. Eventually,
  # we should consider using KMS-based client-side encryption, or uploading it
  # to KMS.
  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(map(
    "Name", "kubeconfig",
    "KubernetesCluster", aws_eks_cluster.vishwakarma.id,
    "Phase", var.phase,
    "Project", var.project
  ), var.extra_tags)
}
