data "aws_region" "current" {}

resource "null_resource" "oidc_thumbprint" {
  provisioner "local-exec" {
    command = "openssl s_client -connect s3-${data.aws_region.current.name}.amazonaws.com:443 -servername s3-${data.aws_region.current.name}.amazonaws.com -showcerts < /dev/null 2>/dev/null  |  openssl x509 -in /dev/stdin -sha1 -noout -fingerprint | cut -d '=' -f 2 | tr -d ':' > .terraform/oidc-thumbprint"
  }
}

data "local_file" "oidc_thumbprint" {
  filename   = ".terraform/oidc-thumbprint"
  depends_on = [null_resource.oidc_thumbprint]
}

resource "aws_iam_openid_connect_provider" "irsa" {
  url = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"

  client_id_list = [var.oidc_api_audiences]

  thumbprint_list = [chomp(data.local_file.oidc_thumbprint.content)]
}

data "template_file" "discovery_json" {
  template = file("${path.module}/resources/discovery.json")

  vars = {
    issuer_host = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"
  }
}

resource "aws_s3_bucket_object" "discovery_json" {
  bucket = var.oidc_s3_bucket

  key          = ".well-known/openid-configuration"
  content      = data.template_file.discovery_json.rendered
  acl          = "public-read"
  content_type = "application/json"

  tags = merge(module.label.tags, map(
    "Name", "discovery.json",
    "Role", "k8s-master"
  ))
}

data "local_file" "keys_json" {
  filename = "./deploy/secrets/keys.json"
}

resource "aws_s3_bucket_object" "keys_json" {
  bucket = var.oidc_s3_bucket

  key          = "keys.json"
  content      = data.local_file.keys_json.content
  acl          = "public-read"
  content_type = "application/json"


  tags = merge(module.label.tags, map(
    "Name", "keys.json",
    "Role", "k8s-master"
  ))
}