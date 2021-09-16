locals {
  private_zone_name = coalesce(var.hostzone, format("%s.com", module.label.id))
  etcd_sg_id        = coalesce(var.etcd_security_group_id, join("", aws_security_group.etcd.*.id))

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
  source           = "../../modules/aws/bastion"
  key_name = var.key_pair_name
  name             = module.label.id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets[0]
  extra_tags       = module.label.tags
}

resource "aws_route53_zone" "private" {
  name = local.private_zone_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = merge(
    module.label.tags, 
    {
      Name = local.private_zone_name,
      Role = "etcd"
    }
  )
}

resource "aws_security_group" "etcd" {
  name_prefix = "${module.label.id}-etcd-"
  vpc_id      = module.vpc.vpc_id

  tags = merge(module.label.tags,
    {
      Name = "${module.label.id}-etcd",
      Role = "etcd"
    }
  )
}

resource "aws_security_group_rule" "etcd_egress" {
  type              = "egress"
  security_group_id = local.etcd_sg_id

  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "etcd_ingress_icmp" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "etcd_ingress_etcd" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "etcd_all_self" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol  = -1
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "etcd_ssh" {
  type              = "ingress"
  security_group_id = local.etcd_sg_id

  protocol    = "tcp"
  cidr_blocks = [module.vpc.vpc_cidr_block]
  from_port   = 22
  to_port     = 22
}
