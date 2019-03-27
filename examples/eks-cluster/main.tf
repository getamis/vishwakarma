module "network" {
  source           = "../../modules/aws//network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${var.key_pair_name}"
}

module "master" {
  source                = "../../modules/aws/eks//master"
  aws_region            = "${var.aws_region}"
  exist_vpc_id          = "${module.network.vpc_id}"
  exist_subnet_ids      = "${module.network.private_subnet_ids}"
  config_output_path    = "${var.config_output_path}"
}
