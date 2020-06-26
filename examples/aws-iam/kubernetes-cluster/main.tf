# ---------------------------------------------------------------------------------------------------------------------
# Naming and Tags
# ---------------------------------------------------------------------------------------------------------------------

module "label" {
  source      = "../../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  name             = module.label.id
  extra_tags       = module.label.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  source = "../../../modules/aws/elastikube"

  name         = module.label.id
  service_cidr = var.service_cidr
  cluster_cidr = var.cluster_cidr

  enable_auth  = true
  enable_irsa  = true
  enable_audit = true

  etcd_config = {
    instance_count     = "1"
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"
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

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  reboot_strategy        = "off"
  
  extra_tags = module.label.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "../../../modules/aws/kube-worker"

  cluster_name      = module.label.id
  kube_service_cidr = var.service_cidr

  security_group_ids = module.master.worker_sg_ids
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

  s3_bucket = module.master.ignition_s3_bucket
  ssh_key   = var.key_pair_name

  extra_tags = module.label.tags
}
