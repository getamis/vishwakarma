resource "aws_spot_fleet_request" "workers" {
  count                               = "${var.aws_az_number}"
  iam_fleet_role                      = "${data.aws_iam_role.spot_fleet.arn}"
  load_balancers                      = "${var.load_balancers}"
  target_group_arns                   = "${var.target_group_arns}"
  spot_price                          = "0.1"
  allocation_strategy                 = "diversified"
  target_capacity                     = "${var.instance_count}"
  valid_until                         = "3000-01-01T00:00:00Z"
  replace_unhealthy_instances         = true
  terminate_instances_with_expiration = true

  provisioner "local-exec" {
    command = "echo ${module.worker_common.workers_profile_arn}"
  }

  launch_specification {
    instance_type     = "${element(keys(var.ec2_type), 0)}"
    spot_price        = "${element(values(var.ec2_type), 0)}"
    weighted_capacity = 1

    ami                      = "${coalesce(var.ec2_ami, module.worker_common.coreos_ami_id)}"
    key_name                 = "${var.ssh_key}"
    subnet_id                = "${var.subnet_ids[count.index]}"
    vpc_security_group_ids   = ["${var.sg_ids}"]
    iam_instance_profile_arn = "${module.worker_common.workers_profile_arn}"
    user_data                = "${module.worker_common.ign_config_rendered}"

    root_block_device {
      volume_type = "${var.root_volume_type}"
      volume_size = "${var.root_volume_size}"
      iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
    }

    tags = "${merge(map(
          "Name", "${var.cluster_name}-${var.worker_name}",
          "kubernetes.io/cluster/${var.cluster_name}", "owned",
          "Phase", "${var.phase}",
          "Project", "${var.project}"
        ), var.extra_tags)}"
  }

  launch_specification {
    instance_type     = "${element(keys(var.ec2_type), 1)}"
    spot_price        = "${element(values(var.ec2_type), 1)}"
    weighted_capacity = 1

    ami                      = "${coalesce(var.ec2_ami, module.worker_common.coreos_ami_id)}"
    key_name                 = "${var.ssh_key}"
    subnet_id                = "${var.subnet_ids[count.index]}"
    vpc_security_group_ids   = ["${var.sg_ids}"]
    iam_instance_profile_arn = "${module.worker_common.workers_profile_arn}"
    user_data                = "${module.worker_common.ign_config_rendered}"

    root_block_device {
      volume_type = "${var.root_volume_type}"
      volume_size = "${var.root_volume_size}"
      iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
    }

    tags = "${merge(map(
          "Name", "${var.cluster_name}-${var.worker_name}",
          "kubernetes.io/cluster/${var.cluster_name}", "owned",
          "Phase", "${var.phase}",
          "Project", "${var.project}"
        ), var.extra_tags)}"
  }

  depends_on = [
    "module.worker_common"
  ]
}

data "aws_iam_role" "spot_fleet" {
  name = "AWSServiceRoleForEC2SpotFleet"
}
