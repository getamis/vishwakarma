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

locals {
  cluster_cidr = var.network_plugin == "amazon-vpc" ? module.vpc.vpc_cidr_block : var.cluster_cidr

  vpc = {
    cidr            = "10.0.0.0/16"
    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name = module.label.id
  cidr = local.vpc["cidr"]

  azs             = local.vpc["azs"]
  private_subnets = local.vpc["private_subnets"]
  public_subnets  = local.vpc["public_subnets"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  tags = module.label.tags
}

module "bastion" {
  source           = "../../../modules/aws/bastion"
  key_name = var.key_pair_name
  name             = module.label.id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets[0]
  extra_tags       = module.label.tags
}

module "os_ami" {
  source          = "../../../modules/aws/os-ami"
  flavor          = "fedora_coreos"
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

    instance_warmup        = 30
    min_healthy_percentage = 100

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_instance_pools                      = 1
  }

  hostzone               = "${var.project}.cluster"
  endpoint_public_access = var.endpoint_public_access
  private_subnet_ids     = module.vpc.private_subnets
  public_subnet_ids      = module.vpc.public_subnets
  ssh_key                = var.key_pair_name
  auto_updates           = "false"

  extra_tags = module.label.tags

  extra_ignition_file_ids = concat(
    module.irsa.ignitions_files,
    module.iam_auth.ignitions_files,
  )
}
