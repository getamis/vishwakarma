locals {
  private_zone_name = coalesce(var.hostzone, format("%s.com", module.label.id))
}

module "label" {
  source      = "../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

module "network" {
  source           = "../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  name             = module.label.id
  extra_tags       = module.label.tags
}

module "os_ami" {
  source          = "../../modules/aws/os-ami"
  flavor          = "flatcar"
  channel         = "alpha"
  flatcar_version = "3760.0.0"
}

module "etcd" {
  source = "../../modules/aws/kube-etcd"

  name             = module.label.id
  ssh_key          = var.key_pair_name
  allowed_ssh_cidr = [module.network.vpc_cidr]

  instance_config = {
    count              = 3
    image_id           = module.os_ami.image_id
    ec2_type           = "t3.medium"
    root_volume_size   = 40
    data_volume_size   = 100
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/var/lib/etcd"
  }

  subnet_ids                  = module.network.private_subnet_ids
  master_security_group_id    = local.etcd_sg_id
  zone_id                     = aws_route53_zone.private.zone_id
  s3_bucket                   = aws_s3_bucket.ignition.id
  reboot_strategy             = var.reboot_strategy
  certs_validity_period_hours = var.certs_validity_period_hours
  debug_mode                  = var.debug_mode

  extra_tags = module.label.tags
}
