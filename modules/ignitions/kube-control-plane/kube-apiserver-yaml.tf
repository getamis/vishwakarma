data "template_file" "kube_apiserver_yaml" {
  template = file("${path.module}/resources/kubernetes/manifests/kube-apiserver.yaml")

  vars = {
    hyperkube_image = "${var.hyperkube["image_path"]}:${var.hyperkube["image_tag"]}"
    secret_path     = var.secret_path

    etcd_servers   = var.etcd_config["endpoints"]
    etcd_ca_flag   = var.etcd_certs["ca_cert_pem"] != "" ? "- --etcd-cafile=${var.secret_path}/etcd-client-ca.crt" : "# no etcd-client-ca.crt given"
    etcd_cert_flag = var.etcd_certs["client_cert_pem"] != "" ? "- --etcd-certfile=${var.secret_path}/etcd-client.crt" : "# no etcd-client.crt given"
    etcd_key_flag  = var.etcd_certs["client_key_pem"] != "" ? "- --etcd-keyfile=${var.secret_path}/etcd-client.key" : "# no etcd-client.key given"

    anonymous_auth    = var.apiserver_config["anonymous_auth"]
    advertise_address = var.apiserver_config["advertise_address"]
    service_cidr      = var.cluster_config["service_cidr"]

    auth_webhook_flag        = var.apiserver_config["auth_webhook_path"] != "" ? "- --authentication-token-webhook-config-file=${var.apiserver_config["auth_webhook_path"]}/kubeconfig" : "# no authentication token webhook provider"
    auth_mount_volume_block  = var.apiserver_config["auth_webhook_path"] != "" ? join("\n      ", list(local.auth_volume_mount_name, local.auth_volume_mount_path, local.auth_volume_read_only)) : "# no authentication token webhook provider"
    auth_volume_block        = var.apiserver_config["auth_webhook_path"] != "" ? join("\n    ", list(local.auth_volume_name, local.auth_volume_host_path, local.auth_volume_path)) : "# no authentication token webhook provider"
    audit_policy_flag        = var.apiserver_config["audit_policy_path"] != "" ? join("\n    ", list("- --audit-policy-file=${var.apiserver_config["audit_policy_path"]}/policy.yaml", "- --audit-log-path=${var.audit_log_backend["path"]}", "- --audit-log-maxage=${var.audit_log_backend["maxage"]}", "- --audit-log-maxbackup=${var.audit_log_backend["maxbackup"]}", "- --audit-log-maxsize=${var.audit_log_backend["maxsize"]}")) : "# not enable auditing"
    audit_mount_volume_block = var.apiserver_config["audit_policy_path"] != "" ? join("\n      ", list(local.audit_volume_mount_name, local.audit_volume_mount_path, local.audit_volume_read_only)) : "# not enable auditing"
    audit_volume_block       = var.apiserver_config["audit_policy_path"] != "" ? join("\n    ", list(local.audit_volume_name, local.audit_volume_host_path, local.audit_volume_path)) : "# not enable auditing"

    cloud_provider             = var.cloud_provider["name"]
    cloud_provider_config_flag = var.cloud_provider["config"] != "" ? "- --cloud-config=/etc/kubernetes/cloud/config" : "# no cloud provider config given"
  }
}

data "ignition_file" "kube_apiserver_yaml" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${pathexpand(var.manifest_path)}/kube-apiserver.yaml"

  content {
    content = data.template_file.kube_apiserver_yaml.rendered
  }
}

locals {
  auth_volume_mount_name = "- name: auth-webhook-path"
  auth_volume_mount_path = "mountPath: ${var.apiserver_config["auth_webhook_path"]}"
  auth_volume_read_only  = "readOnly: true"

  auth_volume_name      = local.auth_volume_mount_name
  auth_volume_host_path = "hostPath:"
  auth_volume_path      = "  path: ${var.apiserver_config["auth_webhook_path"]}"


  audit_volume_mount_name = "- name: audit-policy-path"
  audit_volume_mount_path = "mountPath: ${var.apiserver_config["audit_policy_path"]}"
  audit_volume_read_only  = "readOnly: true"

  audit_volume_name      = local.audit_volume_mount_name
  audit_volume_host_path = "hostPath:"
  audit_volume_path      = "  path: ${var.apiserver_config["audit_policy_path"]}"
}
