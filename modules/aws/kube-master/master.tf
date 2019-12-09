data "aws_subnet" "subnet" {
  id = var.private_subnet_ids[0]
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

resource "aws_autoscaling_group" "master" {
  name_prefix         = "${var.name}-master-"
  desired_capacity    = var.master_config["instance_count"]
  max_size            = var.master_config["instance_count"] * 3
  min_size            = var.master_config["instance_count"]
  vpc_zone_identifier = var.private_subnet_ids
  load_balancers      = [aws_elb.master_internal.id]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.master.id
        version            = "$Latest"
      }

      override {
        instance_type = var.master_config["ec2_type_1"]
      }

      override {
        instance_type = var.master_config["ec2_type_2"]
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.master_config["on_demand_base_capacity"]
      on_demand_percentage_above_base_capacity = var.master_config["on_demand_percentage_above_base_capacity"]
      spot_instance_pools                      = var.master_config["spot_instance_pools"]
    }
  }

  tags = concat([
    {
      key                 = "Name"
      value               = "${var.name}-master"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ], data.null_data_source.tags.*.outputs)
}

resource "aws_launch_template" "master" {
  instance_type = var.master_config["ec2_type_1"]
  image_id      = data.aws_ami.coreos_ami.image_id
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
      volume_type = var.master_config["root_volume_type"]
      volume_size = var.master_config["root_volume_size"]
      iops        = var.master_config["root_volume_type"] == "io1" ? var.master_config["root_volume_iops"] : var.master_config["root_volume_type"] == "gp2" ? 0 : min(10000, max(100, 3 * var.master_config["root_volume_size"]))
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