locals {
  cluster_name = "${var.phase}-${var.project}"
}



# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  project          = var.project
  phase            = var.phase
  extra_tags       = var.extra_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes" {
  source = "../../modules/aws/elastikube"

  name         = local.cluster_name
  service_cidr = var.service_cidr
  cluster_cidr = var.cluster_cidr

  etcd_config = {
    instance_count   = "1"
    ec2_type         = "t3.medium"
    root_volume_iops = "0"
    root_volume_size = "100"
    root_volume_type = "gp2"
  }

  master_config = {
    instance_count   = "1"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1
  }

  oidc_issuer_confg = {
    issuer        = "https://s3-${var.aws_region}.amazonaws.com/${aws_s3_bucket.oidc.id}"
    api_audiences = var.oidc_api_audiences
  }

  extra_ignition_file_ids         = "${module.ignition_aws_iam_authenticator.files}"
  extra_ignition_systemd_unit_ids = "${module.ignition_aws_iam_authenticator.systemd_units}"

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  reboot_strategy        = "off"
  auth_webhook_path      = var.auth_webhook_path


  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "../../modules/aws/kube-worker"

  cluster_name      = local.cluster_name
  kube_service_cidr = var.service_cidr

  security_group_ids = module.kubernetes.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  worker_config = {
    name             = "spot"
    instance_count   = "1"
    ec2_type_1       = "m5.large"
    ec2_type_2       = "m4.large"
    root_volume_iops = "0"
    root_volume_size = "40"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
  }

  s3_bucket = module.kubernetes.s3_bucket
  ssh_key   = var.key_pair_name

  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}
