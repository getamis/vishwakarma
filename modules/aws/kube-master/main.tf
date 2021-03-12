locals {
  vpc_id = data.aws_subnet.subnet.vpc_id

  extra_tags_keys   = keys(var.extra_tags)
  extra_tags_values = values(var.extra_tags)

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
  id = var.private_subnet_ids[0]
}

data "null_data_source" "tags" {
  count = length(keys(var.extra_tags))

  inputs = {
    key                 = local.extra_tags_keys[count.index]
    value               = local.extra_tags_keys[count.index] == "Name" ? "${local.extra_tags_values[count.index]}-master" : local.extra_tags_values[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master" {
  name_prefix         = "${var.name}-master-"
  desired_capacity    = var.instance_config["count"]
  max_size            = var.instance_config["count"] * 3
  min_size            = var.instance_config["count"]
  vpc_zone_identifier = var.private_subnet_ids
  load_balancers      = [aws_elb.master_internal.id]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.master.id
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

  tags = concat(data.null_data_source.tags.*.outputs, [
    {
      key                 = "kubernetes.io/cluster/${var.name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "Role"
      value               = "k8s-master"
      propagate_at_launch = true
    },
  ])
}

resource "aws_launch_template" "master" {
  instance_type = var.instance_config["ec2_type"][0]
  image_id      = var.instance_config["image_id"]
  name_prefix   = "${var.name}-master-"

  vpc_security_group_ids = compact(concat(
    var.security_group_ids,
    list(local.master_sg_id)
  ))

  iam_instance_profile {
    arn = aws_iam_instance_profile.master.arn
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
