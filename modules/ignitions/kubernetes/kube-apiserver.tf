locals {
  merged_apiserver_flags = merge(
    local.apiserver_flags,
    local.audit_log_flags,
    {
      encryption-provider-config = "${local.config_path}/encryption.yaml"
    },
    var.enable_iam_auth ? {
      authentication-token-webhook-config-file = var.auth_webhook_config_path,
    } : {},
    var.enable_irsa ? {
      service-account-signing-key-file = "${local.pki_path}/sa.key",
      api-audiences                    = "${local.oidc_confg.api_audiences}"
      service-account-issuer           = "${local.oidc_confg.issuer}"
    } : {},
  )
}

data "ignition_file" "bootstrap_token_secret" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/bootstrap-token-secret.yaml"

  content {
    content = templatefile("${path.module}/templates/bootstrap-token/secret.yaml.tpl", {
      id     = var.tls_bootstrap_token["id"]
      secret = var.tls_bootstrap_token["secret"]
    })
  }
}

data "ignition_file" "bootstrap_token_rbac" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/bootstrap-token-rbac.yaml"

  content {
    content = templatefile("${path.module}/templates/bootstrap-token/rbac.yaml.tpl", {})
  }
}

data "ignition_file" "audit_log_policy" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.config_path}/policy.yaml"

  content {
    content = templatefile("${path.module}/templates/configs/audit-policy.yaml.tpl", {
      content = var.audit_log_policy_content
    })
  }
}

data "ignition_file" "encryption_config" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.config_path}/encryption.yaml"

  content {
    content = templatefile("${path.module}/templates/configs/encryption.yaml.tpl", {
      secret = base64encode(var.encryption_secret)
    })
  }
}

data "ignition_file" "kube_apiserver_tpl" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "/opt/kubernetes/kube-apiserver.yaml.tpl"

  content {
    content = templatefile("${path.module}/templates/manifests/kube-apiserver.yaml.tpl", {
      image          = "${local.container["hyperkube"].repo}:${local.container["hyperkube"].tag}"
      pki_path       = local.pki_path
      etcd_pki_path  = local.etcd_pki_path
      log_path       = local.log_path
      config_path    = local.config_path
      secure_port    = var.apiserver_secure_port
      etcd_endpoints = var.etcd_endpoints
      cluster_cidr   = var.pod_network_cidr
      service_cidr   = var.service_network_cidr

      // TODO(k2r2bai): move to merged_apiserver_flags
      cloud_provider    = local.cloud_config.provider
      cloud_config_flag = local.cloud_config.path != "" ? "- --cloud-config=${local.cloud_config.path}" : "# no cloud provider config given"
      extra_flags       = local.merged_apiserver_flags
    })
  }
}
