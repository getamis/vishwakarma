module "label" {
  source      = "../../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

module "network" {
  source           = "../../../modules/aws/network"
  bastion_key_name = var.key_pair_name
  name             = module.label.id
  extra_tags       = module.label.tags
}

locals {
  cluster_cidr = var.network_plugin == "amazon-vpc" ? module.network.vpc_cidr : var.cluster_cidr
}

module "os_ami" {
  source          = "../../../modules/aws/os-ami"
  flavor          = "flatcar"
  flatcar_version = "2512.5.0"
}

module "service_account" {
  source = "../../../modules/tls/private-key"
}

module "irsa" {
  source = "../../../modules/aws/irsa"

  name           = module.label.id
  oidc_s3_bucket = "oidc-${md5(module.label.id)}"
  oidc_pub_key   = module.service_account.public_key_pem
}

module "iam_auth" {
  source = "../../../modules/aws/iam-authenticator"

  name       = module.label.id
  extra_tags = module.label.tags
}

module "master" {
  source = "../../../modules/aws/elastikube"

  name                      = module.label.id
  network_plugin            = var.network_plugin
  kubernetes_version        = var.kubernetes_version
  kube_service_network_cidr = var.service_cidr
  kube_cluster_network_cidr = local.cluster_cidr
  enable_iam_auth           = true
  enable_irsa               = true

  service_account_content = {
    pub_key = module.service_account.public_key_pem
    pri_key = module.service_account.private_key_pem
  }

  irsa_oidc_config = {
    issuer        = "https://${module.irsa.oidc_issuer}"
    api_audiences = module.irsa.oidc_api_audiences
  }

  auth_webhook_kubeconfig_path = module.iam_auth.webhook_kubeconfig_path

  etcd_instance_config = {
    count              = "1"
    image_id           = module.os_ami.image_id
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"
  }

  master_instance_config = {
    count            = 1
    image_id         = module.os_ami.image_id
    ec2_type         = [
      "t3.medium",
      "t2.medium"
    ]
    root_volume_iops = 100
    root_volume_size = 256
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
  }

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.network.private_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids
  ssh_key                = var.key_pair_name
  reboot_strategy        = "off"

  extra_tags = module.label.tags

  extra_ignition_file_ids = concat(
    module.irsa.ignitions_files,
    module.iam_auth.ignitions_files,
  )
}
