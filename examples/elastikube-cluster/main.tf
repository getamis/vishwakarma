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
  aws_az_number    = var.aws_az_number
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes" {
  source = "../../modules/aws/elastikube"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version
  network_plugin     = var.network_plugin
  service_cidr       = var.service_cidr
  cluster_cidr       = var.cluster_cidr

  etcd_config = {
    instance_count   = "3"
    ec2_type         = "t3.medium"
    root_volume_iops = "0"
    root_volume_size = "100"
    root_volume_type = "gp2"
  }

  master_config = {
    instance_count   = "2"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1
  }

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  reboot_strategy        = "off"

  extra_tags = merge(map(
    "Phase", var.phase,
    "Project", var.project,
  ), var.extra_tags)
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_on_demand" {
  source = "../../modules/aws/kube-worker"

  cluster_name       = local.cluster_name
  kubernetes_version = var.kubernetes_version
  network_plugin     = var.network_plugin
  kube_service_cidr  = var.service_cidr

  security_group_ids = module.kubernetes.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  worker_config = {
    name             = "on-demand"
    instance_count   = "2"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
    root_volume_iops = "0"
    root_volume_size = "40"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1
  }

  s3_bucket = module.kubernetes.s3_bucket
  ssh_key   = var.key_pair_name

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

  cluster_name       = local.cluster_name
  kubernetes_version = var.kubernetes_version
  network_plugin     = var.network_plugin
  kube_service_cidr  = var.service_cidr

  security_group_ids = module.kubernetes.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  worker_config = {
    name             = "spot"
    instance_count   = "2"
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
