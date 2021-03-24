locals {
  vpc_id = data.aws_subnet.subnet.vpc_id

  asg_extra_tags = [for k, v in var.extra_tags : { key = k, value = v, propagate_at_launch = true} if k != "Name"]

  iops_by_type       = {
    root = {
      "gp3": max(3000, var.instance_config["root_volume_iops"]),
      "io1": max(100, var.instance_config["root_volume_iops"]),
      "io2": max(100, var.instance_config["root_volume_iops"]),
    }
  }
  throughput_by_type = {
    root = {
      "gp3": 125,
    }
  }
}

data "aws_subnet" "subnet" {
  id = var.subnet_ids[0]
}

resource "aws_autoscaling_group" "worker" {
  name_prefix         = "${var.name}-worker-${var.instance_config["name"]}-"
  desired_capacity    = var.instance_config["count"]
  max_size            = var.instance_config["count"] * 3
  min_size            = var.instance_config["count"]
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_config["ec2_type"]

        content {
          instance_type = override.value
        }
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.instance_config["on_demand_base_capacity"]
      on_demand_percentage_above_base_capacity = var.instance_config["on_demand_percentage_above_base_capacity"]
      spot_instance_pools                      = var.instance_config["spot_instance_pools"]
    }
  }

  tags = concat(local.asg_extra_tags, [
    {
      key                 = "Name"
      value               = "${var.name}-worker-${var.instance_config["name"]}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "Role"
      value               = "k8s-worker"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "${var.enable_autoscaler}"
      propagate_at_launch = true
    }
  ])

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }
}

resource "aws_launch_template" "worker" {
  instance_type = var.instance_config["ec2_type"][0]
  image_id      = var.instance_config["image_id"]
  name_prefix   = "${var.name}-worker-${var.instance_config["name"]}-"

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker.arn
  }

  key_name  = var.ssh_key
  user_data = base64encode(data.ignition_config.s3.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = var.instance_config["root_volume_type"]
      volume_size = var.instance_config["root_volume_size"]
      iops        = lookup(local.iops_by_type.root, var.instance_config["root_volume_type"], null)
      throughput  = lookup(local.throughput_by_type.root, var.instance_config["root_volume_type"], null)
    }
  }

  lifecycle {
    create_before_destroy = true

    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [image_id]
  }
}
