locals {
  cluster_name      = "${var.phase}-${var.project}"
  private_zone_name = coalesce(var.hostzone, format("%s.com", local.cluster_name))
}

module "network" {
  source           = "../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  project          = var.project
  phase            = var.phase
  extra_tags       = var.extra_tags
  aws_az_number    = var.aws_az_number
}

module "etcd" {
  source = "../../modules/aws/kube-etcd"

  name    = local.cluster_name
  ssh_key = var.key_pair_name

  etcd_config = {
    instance_count     = "3"
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"
  }

  subnet_ids                  = module.network.private_subnet_ids
  master_security_group_id    = local.etcd_sg_id
  zone_id                     = aws_route53_zone.private.zone_id
  s3_bucket                   = aws_s3_bucket.ignition.id
  reboot_strategy             = var.reboot_strategy
  certs_validity_period_hours = var.certs_validity_period_hours

  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}
