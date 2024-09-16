# ---------------------------------------------------------------------------------------------------------------------
# Naming and Tags
# ---------------------------------------------------------------------------------------------------------------------

module "label" {
  source      = "../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  name             = module.label.id
  extra_tags       = module.label.tags
}

locals {
  cluster_cidr = var.network_plugin == "amazon-vpc" ? module.network.vpc_cidr : var.cluster_cidr
}

module "os_ami" {
  source          = "../../modules/aws/os-ami"
  flavor          = "flatcar"
  flatcar_version = "3815.2.5"
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  source = "../../modules/aws/elastikube"

  name                      = module.label.id
  kubernetes_version        = var.kubernetes_version
  network_plugin            = var.network_plugin
  kube_service_network_cidr = var.service_cidr
  kube_cluster_network_cidr = local.cluster_cidr

  etcd_instance_config = {
    count              = 1
    image_id           = module.os_ami.image_id
    ec2_type           = "t3.medium"
    root_volume_size   = 40
    data_volume_size   = 100
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/var/lib/etcd"
  }

  master_instance_config = {
    count    = 1
    image_id = module.os_ami.image_id
    ec2_type = [
      "t3.medium",
      "t2.medium"
    ]
    root_volume_iops = 100
    root_volume_size = 256
    root_volume_type = "gp2"

    default_cooldown          = 30
    health_check_grace_period = 30

    suspended_processes = []

    instance_refresh       = false
    instance_warmup        = 30
    min_healthy_percentage = 100

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
    spot_allocation_strategy                 = "lowest-price"
  }

  kubelet_extra_config = {
    # https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#memory_cpu
    # calculate with node size t3.medium 2 cpu, 4Gi mem
    kubeReserved              = "{cpu: 35m, memory: 500Mi, ephemeral-storage: 1Gi}"
    systemReserved            = "{cpu: 35m, memory: 500Mi, ephemeral-storage: 1Gi}"
    evictionSoft              = "{memory.available: 100Mi, nodefs.available: 10%}"
    evictionSoftGracePeriod   = "{memory.available: 1m, nodefs.available: 1m}"
    evictionMaxPodGracePeriod = "90"
  }

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  allowed_ssh_cidr       = [module.network.vpc_cidr]
  enable_eni_prefix      = var.enable_eni_prefix
  enable_asg_life_cycle  = var.enable_asg_life_cycle
  external_snat          = var.external_snat
  enable_network_policy  = var.enable_network_policy
  debug_mode             = var.debug_mode
  log_level              = var.log_level

  extra_tags = module.label.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Nodes (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_on_demand" {
  source = "../../modules/aws/kube-worker"

  name                 = module.label.id
  kubernetes_version   = var.kubernetes_version
  service_network_cidr = var.service_cidr
  network_plugin       = var.network_plugin

  security_group_ids = module.master.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  instance_config = {
    name      = "on-demand"
    count     = 1
    max_count = null
    image_id  = "ami-0e0f99ffaff15079c"
    ec2_type = [
      "t3.medium",
      "t2.medium"
    ]
    root_volume_iops = "0"
    root_volume_size = "40"
    root_volume_type = "gp2"

    default_cooldown          = 30
    health_check_grace_period = 30

    suspended_processes = []

    instance_refresh       = false
    instance_warmup        = 30
    min_healthy_percentage = 100

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = null
    spot_allocation_strategy                 = null
  }

  asg_warm_pool = {
    enabled                     = false
    max_group_prepared_capacity = 0
    min_size                    = 0
    reuse_on_scale_in           = false
  }

  kubelet_config = {
    # https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#memory_cpu
    # calculate with node size t3.medium 2 cpu, 4Gi mem
    kubeReserved              = "{cpu: 35m, memory: 500Mi, ephemeral-storage: 1Gi}"
    systemReserved            = "{cpu: 35m, memory: 500Mi, ephemeral-storage: 1Gi}"
    evictionSoft              = "{memory.available: 100Mi, nodefs.available : 10%}"
    evictionSoftGracePeriod   = "{memory.available: 1m, nodefs.available: 1m}"
    evictionMaxPodGracePeriod = "90"
  }

  s3_bucket             = module.master.ignition_s3_bucket
  ssh_key               = var.key_pair_name
  enable_eni_prefix     = var.enable_eni_prefix
  enable_asg_life_cycle = var.enable_asg_life_cycle
  debug_mode            = var.debug_mode
  log_level             = var.log_level

  extra_tags = module.label.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Nodes (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "../../modules/aws/kube-worker"

  name                 = module.label.id
  service_network_cidr = var.service_cidr
  kubernetes_version   = var.kubernetes_version
  network_plugin       = var.network_plugin

  security_group_ids = module.master.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  instance_config = {
    name      = "spot"
    image_id  = "ami-0e0f99ffaff15079c"
    count     = 1
    max_count = 10
    ec2_type = [
      "m5.large",
      "m4.large"
    ]
    root_volume_iops = 0
    root_volume_size = 40
    root_volume_type = "gp2"

    default_cooldown          = 30
    health_check_grace_period = 30

    suspended_processes = []

    instance_refresh       = false
    instance_warmup        = 30
    min_healthy_percentage = 100

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
    spot_allocation_strategy                 = "lowest-price"
  }

  kubelet_config = {
    # https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#memory_cpu
    # calculate with node size m5.large 2 cpu, 8Gi mem
    kubeReserved              = "{cpu: 35m, memory: 900Mi, ephemeral-storage: 1Gi}"
    systemReserved            = "{cpu: 35m, memory: 900Mi, ephemeral-storage: 1Gi}"
    evictionSoft              = "{memory.available: 100Mi, nodefs.available : 10%}"
    evictionSoftGracePeriod   = "{memory.available: 1m, nodefs.available: 1m}"
    evictionMaxPodGracePeriod = "90"
  }

  s3_bucket             = module.master.ignition_s3_bucket
  ssh_key               = var.key_pair_name
  enable_eni_prefix     = var.enable_eni_prefix
  enable_asg_life_cycle = var.enable_asg_life_cycle
  debug_mode            = var.debug_mode
  log_level             = var.log_level

  extra_tags = module.label.tags
}
