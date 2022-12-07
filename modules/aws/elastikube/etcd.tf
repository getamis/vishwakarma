module "etcd" {
  source = "../../aws/kube-etcd"

  name                   = var.name
  ssh_key                = var.ssh_key
  allowed_ssh_cidr       = var.allowed_ssh_cidr
  allowed_etcd_mgmt_cidr = var.allowed_etcd_mgmt_cidr
  instance_config        = var.etcd_instance_config
  containers             = var.override_containers

  instance_volume_config = var.etcd_instance_volume_config

  subnet_ids                  = var.private_subnet_ids
  master_security_group_id    = module.master.master_sg_id
  zone_id                     = aws_route53_zone.private.zone_id
  s3_bucket                   = aws_s3_bucket.ignition.id
  reboot_strategy             = var.reboot_strategy
  certs_validity_period_hours = var.certs_validity_period_hours
  debug_mode                  = var.debug_mode

  extra_ignition_file_ids         = var.extra_etcd_ignition_file_ids
  extra_ignition_systemd_unit_ids = var.extra_etcd_ignition_systemd_unit_ids
  extra_tags                      = var.extra_tags
}
