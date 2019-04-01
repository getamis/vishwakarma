locals {
  cluster_name = "${var.phase}-${var.project}"
}

provider "aws" {
  version = "2.3.0"
  region  = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../modules/aws/network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${var.key_pair_name}"
  project          = "${var.project}"
  phase            = "${var.phase}"
  extra_tags       = "${var.extra_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS
# ---------------------------------------------------------------------------------------------------------------------
module "eks" {
  source                 = "../../modules/aws/eks"
  aws_region             = "${var.aws_region}"
  kubernetes_version     = "${var.kubernetes_version}"
  project                = "${var.project}"
  phase                  = "${var.phase}"
  exist_subnet_ids       = "${module.network.private_subnet_ids}"
  endpoint_public_access = "${var.endpoint_public_access}"
  worker_groups          = "${var.worker_groups}"
  extra_tags             = "${var.extra_tags}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_on_demand" {
  source = "../../modules/aws/eks-worker"

  cluster_name       = "${local.cluster_name}"
  aws_region         = "${var.aws_region}"
  kubernetes_version = "${var.kubernetes_version}"

  security_group_ids = ["${module.eks.worker_sg_id}"]
  subnet_ids         = ["${module.network.private_subnet_ids}"]

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

  s3_bucket = "${module.eks.s3_bucket}"
  ssh_key   = "${var.key_pair_name}"

  extra_tags = "${merge(map(
      "Phase", "${var.phase}",
      "Project", "${var.project}",
    ), var.extra_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "../../modules/aws/eks-worker"

  cluster_name       = "${local.cluster_name}"
  aws_region         = "${var.aws_region}"
  kubernetes_version = "${var.kubernetes_version}"

  security_group_ids = ["${module.eks.worker_sg_id}"]
  subnet_ids         = ["${module.network.private_subnet_ids}"]

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

  s3_bucket = "${module.eks.s3_bucket}"
  ssh_key   = "${var.key_pair_name}"

  extra_tags = "${merge(map(
      "Phase", "${var.phase}",
      "Project", "${var.project}",
    ), var.extra_tags)}"
}