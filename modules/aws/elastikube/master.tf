module "master" {
  source = "../../aws/kube-master"

  name               = var.name
  ssh_key            = var.ssh_key
  master_config      = var.master_config
  role_name          = var.role_name
  kubernetes_version = var.kubernetes_version

  security_group_ids = var.security_group_ids

  lb_security_group_ids       = var.lb_security_group_ids
  public_subnet_ids           = var.public_subnet_ids
  private_subnet_ids          = var.private_subnet_ids
  endpoint_public_access      = var.endpoint_public_access
  certs_validity_period_hours = var.certs_validity_period_hours

  etcd_endpoints = module.etcd.endpoints

  etcd_certs_config = {
    ca_cert_pem     = module.etcd.ca_cert_pem
    client_key_pem  = module.etcd.client_key_pem
    client_cert_pem = module.etcd.client_cert_pem
  }

  kube_service_cidr = var.service_cidr
  kube_cluster_cidr = var.cluster_cidr

  kube_node_labels = compact(concat(
    list("node-role.kubernetes.io/master"),
    var.extra_master_node_labels
  ))

  kube_node_taints = compact(concat(
    list("node-role.kubernetes.io/master=:NoSchedule"),
    var.extra_master_node_taints
  ))


  s3_bucket       = aws_s3_bucket.ignition.id
  reboot_strategy = var.reboot_strategy

  extra_ignition_file_ids = compact(concat(
    module.ignition_kube_addon_manager.files,
    module.ignition_kube_addon_dns.files,
    module.ignition_kube_addon_proxy.files,
    module.ignition_kube_addon_flannel_vxlan.files,
    var.extra_ignition_file_ids
  ))

  extra_ignition_systemd_unit_ids = compact(concat(
    module.ignition_kube_addon_manager.systemd_units,
    module.ignition_kube_addon_dns.systemd_units,
    module.ignition_kube_addon_proxy.systemd_units,
    module.ignition_kube_addon_flannel_vxlan.systemd_units,
    var.extra_ignition_systemd_unit_ids
  ))

  kubelet_flag_extra_flags = var.kubelet_flag_extra_flags

  extra_tags = var.extra_tags

  auth_webhook_path = var.auth_webhook_path
  audit_policy_path = var.audit_policy_path
  audit_log_backend = var.audit_log_backend
  oidc_issuer_confg = var.oidc_issuer_confg
}
