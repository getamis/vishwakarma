resource "aws_s3_bucket" "oidc" {
  bucket = "${local.cluster_name}-oidc-${md5("${local.cluster_name}-oidc")}"
  acl    = "public-read"

  tags = merge(map(
    "Name", "${local.cluster_name}-oidc-${md5("${local.cluster_name}-oidc")}",
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}

resource "null_resource" "oidc_thumbprint" {
  provisioner "local-exec" {
    command = "openssl s_client -connect s3-${var.aws_region}.amazonaws.com:443 -servername s3-${var.aws_region}.amazonaws.com -showcerts < /dev/null 2>/dev/null  |  openssl x509 -in /dev/stdin -sha1 -noout -fingerprint | cut -d '=' -f 2 | tr -d ':' > ${path.module}/.terraform/oidc_thumbprint"
  }
}

data "local_file" "oidc_thumbprint" {
  filename   = "${path.module}/.terraform/oidc_thumbprint"
  depends_on = [null_resource.oidc_thumbprint]
}

resource "aws_iam_openid_connect_provider" "irsa" {
  url = "https://s3-${var.aws_region}.amazonaws.com/${aws_s3_bucket.oidc.id}"

  client_id_list = [var.oidc_api_audiences]

  thumbprint_list = [chomp(data.local_file.oidc_thumbprint.content)]
}