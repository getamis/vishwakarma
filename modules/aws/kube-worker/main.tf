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
  vpc_security_group_ids = var.enable_extra_sg ? concat([aws_security_group.worker_group[0].id], var.security_group_ids) : var.security_group_ids
  asg_max_size           = var.instance_config["max_count"] != null ? var.instance_config["max_count"] : (var.instance_config["count"] == 0 ? 3 : (var.instance_config["count"] * 3))
}

data "aws_subnet" "subnet" {
  id = var.subnet_ids[0]
}

resource "aws_autoscaling_group" "worker" {
  name_prefix         = "${var.name}-worker-${var.instance_config["name"]}-"
  desired_capacity    = var.instance_config["count"]
  max_size            = local.asg_max_size
  min_size            = var.instance_config["count"]
  vpc_zone_identifier = var.subnet_ids

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

  dynamic "launch_template" {
    for_each = var.asg_warm_pool["enabled"] ? [1] : []

    content {
      id      = aws_launch_template.worker.id
      version = aws_launch_template.worker.latest_version
    }
  }

  dynamic "warm_pool" {
    for_each = var.asg_warm_pool["enabled"] ? [1] : []

    content {
      pool_state                  = "Stopped"
      min_size                    = var.asg_warm_pool["min_size"]
      max_group_prepared_capacity = var.asg_warm_pool["max_group_prepared_capacity"]

      instance_reuse_policy {
        reuse_on_scale_in = var.asg_warm_pool["reuse_on_scale_in"]
      }
    }
  }

  # Cannot add a warm pool to Auto Scaling groups that have a mixed instances policy.
  dynamic "mixed_instances_policy" {
    for_each = var.asg_warm_pool["enabled"] ? [] : [1]

    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.worker.id
          version            = aws_launch_template.worker.latest_version
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
        spot_allocation_strategy                 = var.instance_config["spot_allocation_strategy"]
        spot_instance_pools                      = var.instance_config["spot_instance_pools"]
        spot_max_price                           = var.instance_spot_max_price
      }
    }
  }

  dynamic "tag" {
    for_each = merge(
      var.extra_tags,
      var.extra_asg_tags,
      {
        "Name"                              = "${var.name}-worker-${var.instance_config["name"]}"
        "Role"                              = "k8s-worker"
        "kubernetes.io/cluster/${var.name}" = "owned"
      },
      (var.enable_autoscaler != "true") ? {} : { "k8s.io/cluster-autoscaler/enabled" = "true" },
      (var.enable_node_termination_handler != "true") ? {} : { "aws-node-termination-handler/managed" = "true" },
      (var.instance_spot_max_price == "") ? {} : { "spot-max-price" = var.instance_spot_max_price }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns,
      desired_capacity
    ]
  }
}

resource "aws_launch_template" "worker" {
  instance_type = var.instance_config["ec2_type"][0]
  image_id      = var.instance_config["image_id"]
  name_prefix   = "${var.name}-worker-${var.instance_config["name"]}-"

  vpc_security_group_ids = local.vpc_security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker.arn
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
  source = "git::ssh://git@github.com/getamis/terraform-aws-asg-lifecycle//modules/kubernetes?ref=v1.27.4.1"

  name                           = "${var.name}-worker-${var.instance_config["name"]}"
  cluster_name                   = var.name
  autoscaling_group_name         = aws_autoscaling_group.worker.name
  kubeconfig_s3_bucket           = var.s3_bucket
  kubeconfig_s3_object           = var.s3_object
  kubernetes_node_role           = var.instance_config["name"]
  lambda_function_vpc_subnet_ids = var.subnet_ids

  extra_tags = merge(
    {
      "Name"                              = "${var.name}-worker-${var.instance_config["name"]}"
      "kubernetes.io/cluster/${var.name}" = "owned"
    },
    var.extra_tags,
  )
}