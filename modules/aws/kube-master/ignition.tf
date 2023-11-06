resource "random_id" "bootstrap_token_id" {
  byte_length = 3
}

resource "random_id" "bootstrap_token_secret" {
  byte_length = 8
}

resource "random_password" "encryption_secret" {
  length  = 32
  special = true
}

module "ignition_kubernetes" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-kubernetes//?ref=v1.27.7.0"

  binaries              = var.binaries
  containers            = var.containers
  kubernetes_version    = var.kubernetes_version
  apiserver_secure_port = var.apiserver_secure_port
  service_network_cidr  = var.service_network_cidr
  pod_network_cidr      = var.cluster_network_cidr
  node_cidr_mask_size   = var.node_cidr_mask_size
  network_plugin        = var.network_plugin
  internal_endpoint     = "https://${aws_elb.master_internal.dns_name}"
  etcd_endpoints        = join(",", var.etcd_endpoints)

  tls_bootstrap_token = {
    id     = random_id.bootstrap_token_id.hex
    secret = random_id.bootstrap_token_secret.hex
  }

  kubelet_config = var.kubelet_extra_config

  cloud_provider = "aws"

  kube_proxy_config = var.kube_proxy_config
  coredns_config = merge(var.coredns_config, {
    replicas = var.instance_config["count"]
  })

  kubelet_flags = merge(var.kube_extra_flags["kubelet"], {
    node-labels          = join(",", var.kubelet_node_labels)
    register-with-taints = join(",", var.kubelet_node_taints)
  })

  apiserver_flags          = var.kube_extra_flags["apiserver"]
  controller_manager_flags = var.kube_extra_flags["controller_manager"]
  scheduler_flags          = var.kube_extra_flags["scheduler"]
  components_resource      = var.components_resource
  audit_log_flags          = var.kube_extra_flags["audit_log"]
  audit_log_policy_content = var.audit_log_policy_content
  encryption_secret        = random_password.encryption_secret.result
  enable_iam_auth          = var.enable_iam_auth
  auth_webhook_config_path = var.auth_webhook_kubeconfig_path
  enable_irsa              = var.enable_irsa
  oidc_config              = var.oidc_config
  enable_eni_prefix        = var.enable_eni_prefix
  annotate_pod_ip          = var.annotate_pod_ip
  external_snat            = var.external_snat
  max_pods                 = var.max_pods
  log_level                = var.log_level

  certs = {
    etcd_ca_cert = var.etcd_certs["ca_cert"]

    ca_cert                       = module.kubernetes_ca.cert_pem
    ca_key                        = module.kubernetes_ca.private_key_pem
    admin_cert                    = module.admin_cert.cert_pem
    admin_key                     = module.admin_cert.private_key_pem
    apiserver_cert                = module.apiserver_cert.cert_pem
    apiserver_key                 = module.apiserver_cert.private_key_pem
    apiserver_kubelet_client_cert = module.apiserver_kubelet_client_cert.cert_pem
    apiserver_kubelet_client_key  = module.apiserver_kubelet_client_cert.private_key_pem
    apiserver_etcd_client_cert    = module.apiserver_etcd_client_cert.cert_pem
    apiserver_etcd_client_key     = module.apiserver_etcd_client_cert.private_key_pem
    controller_manager_cert       = module.controller_manager_cert.cert_pem
    controller_manager_key        = module.controller_manager_cert.private_key_pem
    scheduler_cert                = module.scheduler_cert.cert_pem
    scheduler_key                 = module.scheduler_cert.private_key_pem
    front_proxy_ca_cert           = module.front_proxy_ca.cert_pem
    front_proxy_ca_key            = module.front_proxy_ca.private_key_pem
    front_proxy_client_cert       = module.front_proxy_client_cert.cert_pem
    front_proxy_client_key        = module.front_proxy_client_cert.private_key_pem
    sa_pub                        = var.service_account_content.pub_key == "" ? module.service_account.public_key_pem : var.service_account_content.pub_key
    sa_key                        = var.service_account_content.pri_key == "" ? module.service_account.private_key_pem : var.service_account_content.pri_key
  }

  kubelet_cert = {
    algo   = lower(module.kubernetes_ca.algorithm)
    size   = 2048
    expiry = "${var.certs_validity_period_hours}h"
  }
}

module "ignition_docker" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/docker?ref=v1.27.4.0"

  docker_cgroup_driver = "systemd"
  log_level            = var.log_level["docker"]
}

module "ignition_containerd" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/containerd?ref=v1.27.4.0"

  log_level = var.log_level["containerd"]
}

module "ignition_locksmithd" {
  source          = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/locksmithd?ref=v1.27.4.0"
  reboot_strategy = var.reboot_strategy
}

module "ignition_update_ca_certificates" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/update-ca-certificates?ref=v1.27.4.0"
}

module "ignition_sshd" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/sshd?ref=v1.27.4.0"

  enable = var.debug_mode
}

module "ignition_ecr_credentail_provider" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/ecr-credential-provider?ref=v1.27.4.0"
}

module "ignition_systemd_networkd" {
  source = "git::ssh://git@github.com/getamis/terraform-ignition-reinforcements//modules/systemd-networkd?ref=v1.27.4.0"

  log_level = var.log_level["systemd_networkd"]
}
data "ignition_config" "main" {
  files = compact(concat(
    module.ignition_docker.files,
    module.ignition_containerd.files,
    module.ignition_locksmithd.files,
    module.ignition_update_ca_certificates.files,
    module.ignition_sshd.files,
    module.ignition_systemd_networkd.files,
    module.ignition_kubernetes.files,
    module.ignition_kubernetes.cert_files,
    module.ignition_ecr_credentail_provider.files,
    var.extra_ignition_file_ids,
  ))

  systemd = compact(concat(
    module.ignition_docker.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    module.ignition_sshd.systemd_units,
    module.ignition_systemd_networkd.systemd_units,
    module.ignition_kubernetes.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))

}

// TODO: use AWS Secrets Manager to store this, or encryption by KMS.
resource "aws_s3_object" "admin_kubeconfig" {
  bucket  = var.s3_bucket
  key     = "admin.conf"
  content = module.ignition_kubernetes.admin_kubeconfig_content
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(var.extra_tags, {
    "Name"                              = "admin.conf"
    "Role"                              = "k8s-master"
    "kubernetes.io/cluster/${var.name}" = "owned"
  })
}

// TODO: use AWS Secrets Manager to store this, or encryption by KMS.
resource "aws_s3_object" "bootstrapping_kubeconfig" {
  bucket  = var.s3_bucket
  key     = "bootstrap-kubelet.conf"
  content = module.ignition_kubernetes.bootstrap_kubeconfig_content
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(var.extra_tags, {
    "Name"                              = "bootstrap-kubelet.conf"
    "Role"                              = "k8s-master"
    "kubernetes.io/cluster/${var.name}" = "owned"
  })
}

resource "aws_s3_object" "ignition" {
  bucket  = var.s3_bucket
  key     = "ign-master-${var.name}.json"
  content = data.ignition_config.main.rendered

  server_side_encryption = "AES256"

  tags = merge(var.extra_tags, {
    "Name"                              = "ign-master-${var.name}.json"
    "Role"                              = "k8s-master"
    "kubernetes.io/cluster/${var.name}" = "owned"
  })
}

data "ignition_config" "s3" {
  replace {
    source       = format("s3://%s/%s", var.s3_bucket, aws_s3_object.ignition.key)
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}
