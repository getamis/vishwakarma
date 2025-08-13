module "master" {
  source = "../../aws/kube-master"

  name             = var.name
  ssh_key          = var.ssh_key
  allowed_ssh_cidr = var.allowed_ssh_cidr

  instance_config         = var.master_instance_config
  instance_spot_max_price = var.master_instance_spot_max_price

  role_name                             = var.role_name
  security_group_ids                    = var.security_group_ids
  lb_security_group_ids                 = var.lb_security_group_ids
  lb_master_connection_draining         = var.lb_master_connection_draining
  lb_master_connection_draining_timeout = var.lb_master_connection_draining_timeout
  lb_master_idle_timeout                = var.lb_master_idle_timeout
  public_subnet_ids                     = var.public_subnet_ids
  private_subnet_ids                    = var.private_subnet_ids
  endpoint_public_access                = var.endpoint_public_access
  s3_bucket                             = aws_s3_bucket.ignition.id

  containers          = var.override_containers
  binaries            = var.override_binaries
  components_resource = var.override_components_resource
  kubernetes_version  = var.kubernetes_version
  network_plugin      = var.network_plugin

  etcd_endpoints          = module.etcd.endpoints
  service_account_content = var.service_account_content

  etcd_certs = {
    ca_cert = module.etcd.ca_cert
    ca_key  = module.etcd.ca_key
  }

  service_network_cidr = var.kube_service_network_cidr
  cluster_network_cidr = var.kube_cluster_network_cidr
  node_cidr_mask_size  = var.kube_node_cidr_mask_size

  kube_extra_flags     = var.kube_extra_flags
  kubelet_extra_config = var.kubelet_extra_config

  // Nodes are not permitted to assert their own role labels. See https://github.com/kubernetes/kubernetes/issues/84912.
  kubelet_node_labels = var.kubelet_node_labels

  kubelet_node_taints = compact(concat(
    ["node-role.kubernetes.io/master=:NoSchedule"],
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

  enable_eni_prefix      = var.enable_eni_prefix
  external_snat          = var.external_snat
  enable_network_policy  = var.enable_network_policy
  ip_allocation_strategy = var.ip_allocation_strategy
  max_pods               = var.max_pods

  enable_asg_life_cycle = var.enable_asg_life_cycle

  audit_log_policy_content = var.kube_audit_log_policy_content

  certs_validity_period_hours = var.certs_validity_period_hours
  reboot_strategy             = var.reboot_strategy
  debug_mode                  = var.debug_mode
  log_level                   = var.log_level
  extra_tags                  = var.extra_tags
}
