module "network" {
  source           = "../../aws//network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${var.bastion_key_name}"
}

module "eks_cluseter" {
  source            = "../../aws/kubernetes/master//eks"
  aws_region        = "${var.aws_region}"
  exist_vpc_id      = "${module.network.vpc_id}"
  exist_subnet_ids  = "${module.network.private_subnet_ids}"
}
