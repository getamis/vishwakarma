module "label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  environment = var.environment
  namespace   = var.project
  name        = var.name
  label_order = ["environment", "namespace", "name"]
  tags        = {
    Project   = var.project
    Service   = var.service
    CreatedBy = "Terraform"
    BuiltWith = "Vishwakarma"
  }
}

module "os_ami" {
  source          = "../../modules/aws/os-ami"
  flavor          = "fedora_coreos"
}

module "etcd" {
  source = "../../modules/aws/kube-etcd"

  name    = module.label.id
  ssh_key = var.key_pair_name

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

  subnet_ids                  = module.vpc.private_subnets
  master_security_group_id    = local.etcd_sg_id
  zone_id                     = aws_route53_zone.private.zone_id
  s3_bucket                   = aws_s3_bucket.ignition.id
  auto_updates                = var.auto_updates
  certs_validity_period_hours = var.certs_validity_period_hours

  extra_tags = module.label.tags
}
