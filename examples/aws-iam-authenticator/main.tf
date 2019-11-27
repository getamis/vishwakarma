locals {
  project            = "elastikube"
  phase              = "auth"
  cluster_name       = "${local.phase}-${local.project}"
  hostzone           = "${local.cluster_name}.cluster"
  kubernetes_version = "v1.13.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "1.60.0"
  region  = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../modules/aws/network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${var.key_pair_name}"
  project          = "${local.project}"
  phase            = "${local.phase}"
  extra_tags       = "${var.extra_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes" {
  source = "../../modules/aws/elastikube"

  name               = "${local.cluster_name}"
  aws_region         = "${var.aws_region}"
  kubernetes_version = "${local.kubernetes_version}"
  service_cidr       = "${var.service_cidr}"
  cluster_cidr       = "${var.cluster_cidr}"

  etcd_config = {
    instance_count   = "3"
    ec2_type         = "t3.medium"
    root_volume_iops = "0"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  master_config = {
    instance_count   = "2"
    ec2_type         = "t3.medium"
    root_volume_iops = "0"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  extra_ignition_file_ids         = "${module.ignition_aws_iam_authenticator.files}"
  extra_ignition_systemd_unit_ids = "${module.ignition_aws_iam_authenticator.systemd_units}"

  hostzone               = "${local.project}.cluster"
  endpoint_public_access = "${var.endpoint_public_access}"
  private_subnet_ids     = ["${module.network.private_subnet_ids}"]
  public_subnet_ids      = ["${module.network.public_subnet_ids}"]
  ssh_key                = "${var.key_pair_name}"
  reboot_strategy        = "off"

  auth_webhook_path = "${var.auth_webhook_path}"

  extra_tags = "${merge(map(
      "Phase", "${local.phase}",
      "Project", "${local.project}",
    ), var.extra_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_on_demand" {
  source = "../../modules/aws/kube-worker"

  cluster_name       = "${local.cluster_name}"
  aws_region         = "${var.aws_region}"
  kubernetes_version = "${local.kubernetes_version}"
  kube_service_cidr  = "${var.service_cidr}"

  security_group_ids = ["${module.kubernetes.worker_sg_ids}"]
  subnet_ids         = ["${module.network.private_subnet_ids}"]

  worker_config = {
    name             = "on_demand"
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

  s3_bucket = "${module.kubernetes.s3_bucket}"
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
  source = "../../modules/aws/kube-worker"

  cluster_name       = "${local.cluster_name}"
  aws_region         = "${var.aws_region}"
  kubernetes_version = "${local.kubernetes_version}"
  kube_service_cidr  = "${var.service_cidr}"

  security_group_ids = ["${module.kubernetes.worker_sg_ids}"]
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

  s3_bucket = "${module.kubernetes.s3_bucket}"
  ssh_key   = "${var.key_pair_name}"

  extra_tags = "${merge(map(
      "Phase", "${local.phase}",
      "Project", "${local.project}",
    ), var.extra_tags)}"
}
