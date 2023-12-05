# ---------------------------------------------------------------------------------------------------------------------
# EKS Distro
# ---------------------------------------------------------------------------------------------------------------------

locals {
  override_master_containers = {
    etcd = {
      repo = "public.ecr.aws/eks-distro/etcd-io/etcd"
      tag  = "v3.4.14-eks-1-18-1"
    }
    kube_apiserver = {
      repo = "public.ecr.aws/eks-distro/kubernetes/kube-apiserver"
      tag  = "v1.18.9-eks-1-18-1"
    }
    kube_controller_manager = {
      repo = "public.ecr.aws/eks-distro/kubernetes/kube-controller-manager"
      tag  = "v1.18.9-eks-1-18-1"
    }
    kube_scheduler = {
      repo = "public.ecr.aws/eks-distro/kubernetes/kube-scheduler"
      tag  = "v1.18.9-eks-1-18-1"
    }
    kube_proxy = {
      repo = "public.ecr.aws/eks-distro/kubernetes/kube-proxy"
      tag  = "v1.18.9-eks-1-18-1"
    }
    coredns = {
      repo = "public.ecr.aws/eks-distro/coredns/coredns"
      tag  = "v1.7.0-eks-1-18-1"
    }
    pause = {
      repo = "public.ecr.aws/eks-distro/kubernetes/pause"
      tag  = "v1.18.9-eks-1-18-1"
    }
  }

  override_worker_containers = {
    pause = {
      repo = "public.ecr.aws/eks-distro/kubernetes/pause"
      tag  = "v1.18.9-eks-1-18-1"
    }
  }
}

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
  flatcar_version = "3602.2.1"
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  source = "../../modules/aws/elastikube"

  name                      = module.label.id
  kubernetes_version        = var.kubernetes_version
  override_containers       = local.override_master_containers
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
    count    = 2
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

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  allowed_ssh_cidr       = [module.network.vpc_cidr]
  reboot_strategy        = "off"

  extra_tags = module.label.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Nodes (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_on_demand" {
  source = "../../modules/aws/kube-worker"

  name                 = module.label.id
  kubernetes_version   = var.kubernetes_version
  containers           = local.override_worker_containers
  service_network_cidr = var.service_cidr
  network_plugin       = var.network_plugin

  security_group_ids = module.master.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  instance_config = {
    name      = "on-demand"
    count     = 1
    max_count = null
    image_id  = module.os_ami.image_id
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
    enabled = false
  }

  s3_bucket = module.master.ignition_s3_bucket
  ssh_key   = var.key_pair_name

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
  containers           = local.override_worker_containers
  network_plugin       = var.network_plugin

  security_group_ids = module.master.worker_sg_ids
  subnet_ids         = module.network.private_subnet_ids

  instance_config = {
    name      = "spot"
    image_id  = module.os_ami.image_id
    count     = 2
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

  s3_bucket = module.master.ignition_s3_bucket
  ssh_key   = var.key_pair_name

  extra_tags = module.label.tags
}
