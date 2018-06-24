resource "aws_launch_configuration" "workers" {
  instance_type        = "${var.ec2_type}"
  image_id             = "${coalesce(var.ec2_ami, module.worker_common.coreos_ami_id)}"
  name_prefix          = "${var.cluster_name}-${var.worker_name}-"
  key_name             = "${var.ssh_key}"
  security_groups      = ["${var.sg_ids}"]

  iam_instance_profile = "${module.worker_common.workers_profile_arn}"
  user_data            = "${module.worker_common.ign_config_rendered}"

  lifecycle {
    create_before_destroy = true

    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["image_id"]
  }

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    iops        = "${var.root_volume_type == "io1" ? var.root_volume_iops : 0}"
  }
}

resource "aws_autoscaling_group" "workers" {
  name                 = "${var.cluster_name}-${var.worker_name}"
  desired_capacity     = "${var.instance_count}"
  max_size             = "${var.instance_count * 3}"
  min_size             = "${var.instance_count}"
  launch_configuration = "${aws_launch_configuration.workers.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-${var.worker_name}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "Phase"
      value               = "${var.phase}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
    },
    "${var.extra_tags}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "workers" {
  count = "${length(var.load_balancers)}"

  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
  elb                    = "${var.load_balancers[count.index]}"
}

resource "aws_autoscaling_attachment" "workers_target_group" {
  count = "${length(var.target_group_arns)}"

  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
  alb_target_group_arn   = "${var.target_group_arns[count.index]}"
}
