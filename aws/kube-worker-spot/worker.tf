data "aws_subnet" "subnet" {
  id = "${var.subnet_ids[0]}"
}

locals {
  vpc_id = "${data.aws_subnet.subnet.vpc_id}"
}

resource "aws_spot_fleet_request" "worker" {
  count                               = "${length(var.subnet_ids)}"
  iam_fleet_role                      = "${aws_iam_role.spot_fleet.arn}"
  load_balancers                      = ["${var.load_balancer_ids}"]
  target_group_arns                   = ["${var.target_group_arns}"]
  spot_price                          = "${var.worker_config["price"]}"
  allocation_strategy                 = "diversified"
  target_capacity                     = "${var.worker_config["min_instance_count"]}"
  valid_until                         = "3000-01-01T00:00:00Z"
  replace_unhealthy_instances         = true
  terminate_instances_with_expiration = true

  launch_specification {
    instance_type     = "${var.worker_config["ec2_type"]}"
    spot_price        = "${var.worker_config["price"]}"
    weighted_capacity = 1

    ami                      = "${data.aws_ami.coreos_ami.image_id}"
    key_name                 = "${var.ssh_key}"
    subnet_id                = "${var.subnet_ids[count.index]}"
    vpc_security_group_ids   = ["${var.security_group_ids}"]
    iam_instance_profile_arn = "${aws_iam_instance_profile.worker.arn}"
    user_data                = "${data.ignition_config.s3.rendered}"

    root_block_device {
      volume_type = "${var.worker_config["root_volume_type"]}"
      volume_size = "${var.worker_config["root_volume_size"]}"
      iops        = "${var.worker_config["root_volume_type"] == "io1" ? var.worker_config["root_volume_iops"] : var.worker_config["root_volume_type"] == "gp2" ? 0 : min(10000, max(100, 3 * var.worker_config["root_volume_size"]))}"
    }

    tags = "${merge(map(
          "Name", "${var.name}-worker-${var.worker_config["name"]}-${count.index}",
          "kubernetes.io/cluster/${var.name}", "owned"
        ), var.extra_tags)}"
  }
}

resource "aws_appautoscaling_target" "worker" {
  count              = "${length(var.subnet_ids)}"
  min_capacity       = "${var.worker_config["min_instance_count"]}"
  max_capacity       = "${var.worker_config["max_instance_count"]}"
  resource_id        = "spot-fleet-request/${aws_spot_fleet_request.worker.*.id[count.index]}"
  role_arn           = "${aws_iam_role.spot_fleet.arn}"
  scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace  = "ec2"
}

resource "aws_appautoscaling_policy" "worker" {
  count              = "${length(var.subnet_ids)}"
  name               = "${join("", aws_spot_fleet_request.worker.*.id)}-${count.index}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.worker.*.resource_id[count.index]}"
  scalable_dimension = "${aws_appautoscaling_target.worker.*.scalable_dimension[count.index]}"
  service_namespace  = "${aws_appautoscaling_target.worker.*.service_namespace[count.index]}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "EC2SpotFleetRequestAverageCPUUtilization"
    }

    target_value = 70
  }
}
