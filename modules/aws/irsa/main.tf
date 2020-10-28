data "aws_region" "current" {}

module "ignition_pod_idenity_webhook" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-kubernetes//modules/extra-addons/aws-pod-identity-webhook?ref=master"

  container             = var.container
  webhook_flags         = var.webhook_flags
  addons_dir_path       = var.kube_addons_dir_path
  tls_cert_ca           = module.webhook_ca.cert_pem
  tls_cert              = module.webhook_cert.cert_pem
  tls_key               = module.webhook_cert.private_key_pem
  located_control_plane = true
}

data "external" "thumbprint" {
  program = ["${path.module}/tools/thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "irsa" {
  url = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"

  client_id_list  = [var.oidc_api_audiences]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
}

resource "local_file" "oidc_pub_key" {
  content  = var.oidc_pub_key
  filename = "${path.root}/.secret/oidc-pkcs8.pub"
}

resource "null_resource" "generate_oidc_keys_json" {
  provisioner "local-exec" {
    command = "go run ${path.module}/tools/self-hosted/main.go -key $PKCS_KEY  | jq '.keys += [.keys[0]] | .keys[1].kid = \"\"' > ${path.root}/.secret/keys.json"

    environment = {
      GO111MODULE = "on"
      PKCS_KEY    = "${path.root}/.secret/oidc-pkcs8.pub"
    }
  }

  triggers = {
    controller_primary = timestamp()
  }

  depends_on = [local_file.oidc_pub_key]
}

resource "aws_s3_bucket" "oidc" {
  bucket = var.oidc_s3_bucket
  acl    = "private"

  tags = merge(
    map("Name", "${var.name}-oidc-${md5("${var.name}-oidc")}"),
  var.extra_tags)
}

resource "aws_s3_bucket_object" "discovery_json" {
  bucket = aws_s3_bucket.oidc.id

  key          = ".well-known/openid-configuration"
  acl          = "public-read"
  content_type = "application/json"

  content = templatefile("${path.module}/templates/discovery.json.tpl", {
    issuer_host = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"
  })

  tags = merge(map(
    "Name", "discovery.json",
    "Role", "k8s-master"
  ), var.extra_tags)
}

data "local_file" "keys_json" {
  filename   = "${path.root}/.secret/keys.json"
  depends_on = [null_resource.generate_oidc_keys_json]
}

resource "aws_s3_bucket_object" "keys_json" {
  bucket = aws_s3_bucket.oidc.id

  key          = "keys.json"
  content      = data.local_file.keys_json.content
  acl          = "public-read"
  content_type = "application/json"

  tags = merge(map(
    "Name", "keys.json",
    "Role", "k8s-master"
  ), var.extra_tags)
}
