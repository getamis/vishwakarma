data "aws_subnet" "subnet" {
  id = var.subnet_ids[0]
}

locals {
  vpc_id = data.aws_subnet.subnet.vpc_id

  extra_tags_keys   = keys(var.extra_tags)
  extra_tags_values = values(var.extra_tags)
}

data "null_data_source" "tags" {
  count = length(keys(var.extra_tags))

  inputs = {
    key                 = local.extra_tags_keys[count.index]
    value               = local.extra_tags_values[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name_prefix          = "${var.cluster_name}-worker-${var.worker_config["name"]}-"
  desired_capacity     = var.worker_config["instance_count"]
  max_size             = var.worker_config["instance_count"] * 3
  min_size             = var.worker_config["instance_count"]
  vpc_zone_identifier  = var.subnet_ids
  load_balancers       = var.load_balancer_ids
  target_group_arns    = var.target_group_arns

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker.id
        version = "$Latest"
      }

      override {
        instance_type = var.worker_config["ec2_type_1"]
      }

      override {
        instance_type = var.worker_config["ec2_type_2"]
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.worker_config["on_demand_base_capacity"]
      on_demand_percentage_above_base_capacity = var.worker_config["on_demand_percentage_above_base_capacity"]
      spot_instance_pools                      = var.worker_config["spot_instance_pools"]
    }
  }

  tags = concat([
    {
      key                 = "Name"
      value               = "${var.cluster_name}-worker-${var.worker_config["name"]}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "${var.enable_autoscaler}"
      propagate_at_launch = true
    }
  ], data.null_data_source.tags.*.outputs)
}

resource "aws_launch_template" "worker" {
  instance_type = var.worker_config["ec2_type_1"]
  image_id      = data.aws_ami.coreos_ami.image_id
  name_prefix   = "${var.cluster_name}-worker-${var.worker_config["name"]}-"  

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker.arn
  }

  key_name  = var.ssh_key
  user_data = base64encode(data.ignition_config.s3.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = var.worker_config["root_volume_type"]
      volume_size = var.worker_config["root_volume_size"]
      iops        = var.worker_config["root_volume_type"] == "io1" ? var.worker_config["root_volume_iops"] : var.worker_config["root_volume_type"] == "gp2" ? 0 : min(10000, max(100, 3 * var.worker_config["root_volume_size"]))
    }
  }

  lifecycle {
    create_before_destroy = true

    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["image_id"]
  }
}
