locals {
  vpc_id      = data.aws_subnet.subnet.vpc_id
  client_port = 2379
  peer_port   = 2380
}

data "aws_subnet" "subnet" {
  id = var.subnet_ids[0]
}

data "null_data_source" "tags" {
  count = length(keys(var.extra_tags))

  inputs = {
    key                 = local.extra_tags_keys[count.index]
    value               = local.extra_tags_values[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "etcd" {
  name_prefix         = "${var.name}-etcd-"
  desired_capacity    = var.etcd_config["instance_count"]
  max_size            = var.etcd_config["instance_count"] * 3
  min_size            = var.etcd_config["instance_count"]
  vpc_zone_identifier = var.subnet_ids
  # load_balancers      = var.load_balancer_ids
  # target_group_arns   = var.target_group_arns

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.etcd.id
        version            = "$Latest"
      }

      override {
        instance_type = var.etcd_config["ec2_type_1"]
      }

      override {
        instance_type = var.etcd_config["ec2_type_2"]
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.etcd_config["on_demand_base_capacity"]
      on_demand_percentage_above_base_capacity = var.etcd_config["on_demand_percentage_above_base_capacity"]
      spot_instance_pools                      = var.etcd_config["spot_instance_pools"]
    }
  }

  tags = concat([
    {
      key                 = "Name"
      value               = "${var.name}-etcd-"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ], data.null_data_source.tags.*.outputs)
}

module "latest_os_ami" {
  source  = "../../aws/latest-os-ami"
  os_name = "coreos"
}

resource "aws_launch_template" "etcd" {
  instance_type = var.etcd_config["ec2_type_1"]
  image_id      = module.latest_os_ami.image_id
  name_prefix   = "${var.name}-etcd-"

  vpc_security_group_ids = compact(concat(
    var.security_group_ids,
    list(aws_security_group.etcd.id)
  ))

  iam_instance_profile {
    arn = aws_iam_instance_profile.etcd.arn
  }

  key_name  = var.ssh_key
  user_data = base64encode(data.ignition_config.s3.rendered)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = var.etcd_config["root_volume_type"]
      volume_size = var.etcd_config["root_volume_size"]
      iops        = var.etcd_config["root_volume_type"] == "io1" ? var.etcd_config["root_volume_iops"] : var.etcd_config["root_volume_type"] == "gp2" ? min(10000, max(100, 3 * var.etcd_config["root_volume_size"])) : 0
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
