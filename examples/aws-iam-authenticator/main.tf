locals {
  project      = "elastikube"
  phase        = "auth"
  cluster_name = "${local.phase}-${local.project}"
  hostzone     = "${local.cluster_name}.cluster"
  kubernetes_version = "v1.10.5"
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "1.23.0"
  region  = "${var.aws_region}"
}

resource "aws_key_pair" "ssh_key" {
  public_key = "${file(pathexpand("~/.ssh/id_rsa.pub"))}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../aws/network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${aws_key_pair.ssh_key.key_name}"
  project          = "${local.project}"
  phase            = "${local.phase}"
  extra_tags       = "${var.extra_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ElastiKube
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes" {
  source = "../../aws/elastikube"

  name         = "${local.cluster_name}"
  aws_region   = "${var.aws_region}"
  version      = "${local.kubernetes_version}"
  service_cidr = "${var.service_cidr}"
  cluster_cidr = "${var.cluster_cidr}"

  etcd_config = {
    instance_count   = "3"
    ec2_type         = "t2.medium"
    root_volume_iops = "0"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  master_config = {
    instance_count   = "2"
    ec2_type         = "t2.medium"
    root_volume_iops = "0"
    root_volume_size = "256"
    root_volume_type = "gp2"
  }

  extra_ignition_file_ids         = "${module.ignition_aws_iam_authenticator.files}"
  extra_ignition_systemd_unit_ids = "${module.ignition_aws_iam_authenticator.systemd_units}"

  hostzone        = "${local.project}.cluster"
  subnet_ids      = ["${module.network.private_subnet_ids}"]
  ssh_key         = "${aws_key_pair.ssh_key.key_name}"
  reboot_strategy = "off"

  auth_webhook_path = "${var.auth_webhook_path}"

  extra_tags = "${merge(map(
      "Phase", "${local.phase}",
      "Project", "${local.project}",
    ), var.extra_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_general" {
  source = "../../aws/kube-worker-general"

  name              = "${local.cluster_name}"
  aws_region        = "${var.aws_region}"
  version           = "${local.kubernetes_version}"
  kube_service_cidr = "${var.service_cidr}"

  security_group_ids = ["${module.kubernetes.worker_sg_ids}"]
  subnet_ids         = ["${module.network.private_subnet_ids}"]

  worker_config = {
    name             = "general"
    instance_count   = "2"
    ec2_type         = "t2.medium"
    root_volume_iops = "0"
    root_volume_size = "64"
    root_volume_type = "gp2"
  }

  s3_bucket = "${module.kubernetes.s3_bucket}"
  ssh_key   = "${aws_key_pair.ssh_key.key_name}"

  extra_tags = "${merge(map(
      "Phase", "${local.phase}",
      "Project", "${local.project}",
    ), var.extra_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node (On Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "worker_spot" {
  source = "../../aws/kube-worker-spot"

  name              = "${local.cluster_name}"
  aws_region        = "${var.aws_region}"
  version           = "${local.kubernetes_version}"
  kube_service_cidr = "${var.service_cidr}"

  security_group_ids = ["${module.kubernetes.worker_sg_ids}"]
  subnet_ids         = ["${module.network.private_subnet_ids}"]

  worker_config = {
    name               = "spot"
    min_instance_count = "2"
    max_instance_count = "2"
    ec2_type           = "m4.large"
    price              = "0.04"
    root_volume_iops   = "0"
    root_volume_size   = "64"
    root_volume_type   = "gp2"
  }

  s3_bucket = "${module.kubernetes.s3_bucket}"
  ssh_key   = "${aws_key_pair.ssh_key.key_name}"

  extra_tags = "${merge(map(
      "Phase", "${local.phase}",
      "Project", "${local.project}",
    ), var.extra_tags)}"
}
