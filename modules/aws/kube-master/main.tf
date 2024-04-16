locals {
  vpc_id = data.aws_subnet.subnet.vpc_id

  iops_by_type = {
    root = {
      "gp3" : max(3000, var.instance_config["root_volume_iops"]),
      "io1" : max(100, var.instance_config["root_volume_iops"]),
      "io2" : max(100, var.instance_config["root_volume_iops"]),
    }
  }
  throughput_by_type = {
    root = {
      "gp3" : 125,
    }
  }
}

data "aws_subnet" "subnet" {
  id = var.private_subnet_ids[0]
}

resource "aws_autoscaling_group" "master" {
  name_prefix         = "${var.name}-master-"
  desired_capacity    = var.instance_config["count"]
  max_size            = var.instance_config["count"] * 3
  min_size            = var.instance_config["count"]
  vpc_zone_identifier = var.private_subnet_ids
  load_balancers      = [aws_elb.master_internal.id]

  default_cooldown          = var.instance_config["default_cooldown"]
  health_check_grace_period = var.instance_config["health_check_grace_period"]

  suspended_processes = var.instance_config["suspended_processes"]

  dynamic "instance_refresh" {
    for_each = var.instance_config["instance_refresh"] ? [1] : []
    content {
      strategy = "Rolling"
      preferences {
        instance_warmup        = var.instance_config["instance_warmup"]
        min_healthy_percentage = var.instance_config["min_healthy_percentage"]
      }
    }
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.master.id
        version            = aws_launch_template.master.latest_version
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
      spot_allocation_strategy                 = var.instance_config["spot_allocation_strategy"]
      spot_max_price                           = var.instance_spot_max_price
    }
  }

  dynamic "tag" {
    for_each = merge(var.extra_tags,
      {
        "Name"                              = "${var.name}-master"
        "Role"                              = "k8s-master"
        "kubernetes.io/cluster/${var.name}" = "owned"
      },
      (var.instance_spot_max_price == "") ? {} : { "spot-max-price" = var.instance_spot_max_price }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_launch_template" "master" {
  instance_type = var.instance_config["ec2_type"][0]
  image_id      = var.instance_config["image_id"]
  name_prefix   = "${var.name}-master-"

  vpc_security_group_ids = compact(concat(
    var.security_group_ids,
    [local.master_sg_id]
  ))

  iam_instance_profile {
    arn = aws_iam_instance_profile.master.arn
  }

  key_name  = var.debug_mode ? var.ssh_key : ""
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
  }
}


module "lifecycle_hook" {
  count  = var.enable_asg_life_cycle ? 1 : 0
  source = "git::ssh://git@github.com/getamis/terraform-aws-asg-lifecycle//modules/kubernetes?ref=v1.27.4.2"

  name                           = "${var.name}-master"
  cluster_name                   = var.name
  autoscaling_group_name         = aws_autoscaling_group.master.name
  kubeconfig_s3_bucket           = var.s3_bucket
  kubeconfig_s3_object           = aws_s3_object.admin_kubeconfig.id
  kubernetes_node_role           = "master"
  lambda_function_vpc_subnet_ids = var.private_subnet_ids

  extra_tags = merge(
    {
      "Name"                              = "${var.name}-master"
      "kubernetes.io/cluster/${var.name}" = "owned"
    },
    var.extra_tags,
  )
}