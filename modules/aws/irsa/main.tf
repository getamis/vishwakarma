locals {
  # The fileexists() would be called before `terraform apply`.
  # Besides, we would get the `local_file.keys_json` data source after applying the `local-exec` in `null_resource.generate_oidc_keys_json` source.
  #
  # In the other words, if `keys.json` is not exist, the `null_resource.generate_oidc_keys_json` source would generate it;
  # then, we would have a brand new `keys.json` when we use the content of the `local_file.keys_json` data source.
  keys_json_local_cache_exist = fileexists("${path.root}/.secret/keys.json")
  keys_json_from_local_cache  = local.keys_json_local_cache_exist
}

data "aws_region" "current" {}

module "ignition_pod_idenity_webhook" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-kubernetes//modules/extra-addons/aws-pod-identity-webhook?ref=v1.4.5"

  container                  = var.container
  service_name               = var.service_name
  namespace                  = var.namespace
  replicas                   = var.replicas
  webhook_flags              = var.webhook_flags
  addons_dir_path            = var.kube_addons_dir_path
  mutating_webhook_ca_bundle = module.webhook_ca.cert_pem
  tls_cert                   = module.webhook_cert.cert_pem
  tls_key                    = module.webhook_cert.private_key_pem
  located_control_plane      = true
}

data "external" "thumbprint" {
  program = ["${path.module}/tools/thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "irsa" {
  url = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.oidc_s3_bucket}"

  client_id_list  = [var.oidc_api_audiences]
  thumbprint_list = [lower(data.external.thumbprint.result.thumbprint)]
}

resource "local_file" "oidc_pub_key" {
  content  = var.oidc_pub_key
  filename = "${path.root}/.secret/oidc-pkcs8.pub"
}

resource "null_resource" "generate_oidc_keys_json" {
  provisioner "local-exec" {
    working_dir = "${path.module}/tools/self-hosted"
    command     = "go run main.go -key $PKCS_KEY  | jq '.keys += [.keys[0]] | .keys[1].kid = \"\"' > ${path.cwd}/.secret/keys.json"

    environment = {
      GO111MODULE = "on"
      PKCS_KEY    = "${path.cwd}/.secret/oidc-pkcs8.pub"
    }
  }

  triggers = {
    oidc_pub_key_md5  = md5(var.oidc_pub_key)
    local_cache_exist = local.keys_json_local_cache_exist
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
  count = local.keys_json_from_local_cache ? 0 : 1

  filename   = "${path.root}/.secret/keys.json"
  depends_on = [null_resource.generate_oidc_keys_json]
}

resource "aws_s3_bucket_object" "keys_json" {
  bucket = aws_s3_bucket.oidc.id

  key          = "keys.json"
  content      = local.keys_json_from_local_cache ? file("${path.root}/.secret/keys.json") : data.local_file.keys_json[0].content
  acl          = "public-read"
  content_type = "application/json"

  tags = merge(map(
    "Name", "keys.json",
    "Role", "k8s-master"
  ), var.extra_tags)
}
