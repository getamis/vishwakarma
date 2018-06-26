# ---------------------------------------------------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source           = "../../aws//network"
  aws_region       = "${var.aws_region}"
  bastion_key_name = "${var.key_pair_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Cluster
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  source                = "../../aws/eks//master"
  aws_region            = "${var.aws_region}"
  exist_vpc_id          = "${module.network.vpc_id}"
  exist_subnet_ids      = "${module.network.private_subnet_ids}"
  config_output_path    = "${var.config_output_path}"
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Worker Node (On Demand Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "workers_asg" {
  source = "../../aws/eks//worker-asg"

  cluster_name                         = "${module.master.id}"
  cluster_endpoint                     = "${module.master.endpoint}"
  certificate_authority_data           = "${module.master.certificate_authority_data}"
  worker_name                          = "${var.worker_asg["name"]}"
  ec2_type                             = "${var.worker_asg["ec2_type"]}"
  instance_count                       = "${var.worker_asg["instance_count"]}"
  root_volume_size                     = "${var.worker_asg["root_volume_size"]}"
  root_volume_type                     = "${var.worker_asg["root_volume_type"]}"
  sg_ids                               = ["${module.master.worker_sg_id}"]
  s3_bucket                            = "${module.master.s3_bucket}"
  ssh_key                              = "${var.key_pair_name}"
  subnet_ids                           = "${module.network.private_subnet_ids}"
  vpc_id                               = "${module.network.vpc_id}"
  aws_region                           = "${var.aws_region}"
  container_linux_channel              = "${var.worker_asg["release_channel"]}"
  container_linux_version              = "${var.worker_asg["release_version"]}"
  container_images                     = "${var.container_images}"
  kubelet_node_label                   = "${var.worker_asg["k8s_labels"]}"
  extra_tags                           = "${var.extra_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Worker Node (Spot Instance)
# ---------------------------------------------------------------------------------------------------------------------

module "workers_spot" {
  source = "../../aws/eks//worker-spot"

  cluster_name                         = "${module.master.id}"
  cluster_endpoint                     = "${module.master.endpoint}"
  certificate_authority_data           = "${module.master.certificate_authority_data}"
  worker_name                          = "${var.worker_spot["name"]}"
  ec2_type                             = "${var.spot_ec2_type}"
  instance_count                       = "${var.worker_spot["instance_count"]}"
  root_volume_size                     = "${var.worker_spot["root_volume_size"]}"
  root_volume_type                     = "${var.worker_spot["root_volume_type"]}"
  sg_ids                               = ["${module.master.worker_sg_id}"]
  s3_bucket                            = "${module.master.s3_bucket}"
  ssh_key                              = "${var.key_pair_name}"
  subnet_ids                           = "${module.network.private_subnet_ids}"
  vpc_id                               = "${module.network.vpc_id}"
  aws_region                           = "${var.aws_region}"
  container_linux_channel              = "${var.worker_spot["release_channel"]}"
  container_linux_version              = "${var.worker_spot["release_version"]}"
  container_images                     = "${var.container_images}"
  kubelet_node_label                   = "${var.worker_spot["k8s_labels"]}"
  extra_tags                           = "${var.extra_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes ConfigMap aws-auth for Worker Node Permission
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "patch_aws_auth_cm" {
  template = "${file("./patch-aws-auth-cm.yaml.tpl")}"

  vars {
    worker_asg_role_arn  = "${module.workers_asg.aws_iam_role_arn}"
    worker_spot_role_arn = "${module.workers_spot.aws_iam_role_arn}"
  }
}

resource "local_file" "patch_aws_auth_cm" {
  content  = "${data.template_file.patch_aws_auth_cm.rendered}"
  filename = "${var.config_output_path}/patch-aws-auth-cm.yaml"
}

resource "null_resource" "patch_aws_auth_cm" {
  provisioner "local-exec" {
    command = "kubectl patch configmaps aws-auth --type merge --patch \"$(cat ${var.config_output_path}/patch-aws-auth-cm.yaml)\" --namespace=kube-system --kubeconfig ${var.config_output_path}/kubeconfig "
  }

  triggers {
    worker_asg_role_arn  = "${module.workers_asg.aws_iam_role_arn}"
    worker_spot_role_arn = "${module.workers_spot.aws_iam_role_arn}"
  }

  depends_on = ["module.workers_asg"]
}
