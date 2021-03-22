module "master" {
  source = "../../aws/kube-master"

  name                   = var.name
  ssh_key                = var.ssh_key

  instance_config         = var.master_instance_config
  instance_spot_max_price = var.master_instance_spot_max_price

  role_name              = var.role_name
  security_group_ids     = var.security_group_ids
  lb_security_group_ids  = var.lb_security_group_ids
  public_subnet_ids      = var.public_subnet_ids
  private_subnet_ids     = var.private_subnet_ids
  endpoint_public_access = var.endpoint_public_access
  s3_bucket              = aws_s3_bucket.ignition.id

  containers         = var.override_containers
  binaries           = var.override_binaries
  kubernetes_version = var.kubernetes_version
  network_plugin     = var.network_plugin

  etcd_endpoints          = module.etcd.endpoints
  service_account_content = var.service_account_content

  etcd_certs = {
    ca_cert = module.etcd.ca_cert
    ca_key  = module.etcd.ca_key
  }

  service_network_cidr = var.kube_service_network_cidr
  cluster_network_cidr = var.kube_cluster_network_cidr

  extra_flags = var.kube_extra_flags

  // Nodes are not permitted to assert their own role labels. See https://github.com/kubernetes/kubernetes/issues/84912.
  kubelet_node_labels = var.kubelet_node_labels

  kubelet_node_taints = compact(concat(
    list("node-role.kubernetes.io/master=:NoSchedule"),
    var.kubelet_node_taints
  ))

  extra_ignition_file_ids = compact(concat(
    var.extra_ignition_file_ids
  ))

  extra_ignition_systemd_unit_ids = compact(concat(
    var.extra_ignition_systemd_unit_ids
  ))

  enable_iam_auth              = var.enable_iam_auth
  auth_webhook_kubeconfig_path = var.auth_webhook_kubeconfig_path

  enable_irsa = var.enable_irsa
  oidc_config = var.irsa_oidc_config

  audit_log_policy_content = var.kube_audit_log_policy_content

  certs_validity_period_hours = var.certs_validity_period_hours
  reboot_strategy             = var.reboot_strategy
  extra_tags                  = var.extra_tags
}
