locals {
  vpc_id             = data.aws_subnet.etcd[0].vpc_id
  az_num             = length(data.aws_availability_zones.available.names)
  client_port        = 2379
  peer_port          = 2380
  node_exporter_port = 9100

  iops_by_type       = {
    root = {
      "gp3": max(3000, var.instance_volume_config.root.iops),
      "io1": max(100, var.instance_volume_config.root.iops),
      "io2": max(100, var.instance_volume_config.root.iops),
    }
    data = {
      "gp3": max(3000, var.instance_volume_config.data.iops),
      "io1": max(100, var.instance_volume_config.data.iops),
      "io2": max(100, var.instance_volume_config.data.iops),
    }
  }
  throughput_by_type = {
    root = {
      "gp3": max(125, var.instance_volume_config.root.throughput),
    }
    data = {
      "gp3": max(125, var.instance_volume_config.data.throughput),
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "etcd" {
  count = var.instance_config["count"]
  id    = var.subnet_ids[count.index % length(var.subnet_ids)]
}

resource "aws_network_interface" "etcd" {
  count     = var.instance_config["count"]
  subnet_id = var.subnet_ids[count.index % length(var.subnet_ids)]
  security_groups = compact(concat(
    var.security_group_ids,
    [aws_security_group.etcd.id]
  ))
  source_dest_check = false

  tags = merge(var.extra_tags,
  {
    Name                                = "${var.name}-etcd-${count.index}"
    Role                                = "etcd"
    "kubernetes.io/cluster/${var.name}" = "owned"
  }
  )
}

resource "aws_ebs_volume" "etcd" {
  count             = var.instance_config["count"]
  availability_zone = data.aws_subnet.etcd[count.index].availability_zone
  size              = var.instance_config["data_volume_size"]
  type              = var.instance_volume_config.data.type
  iops              = lookup(local.iops_by_type.data, var.instance_volume_config.data.type, null)
  # aws_ebs_volume always checks the range of throughput.(125 ~ 1000)
  throughput        = lookup(local.throughput_by_type.data, var.instance_volume_config.data.type, null)

  tags = merge(var.extra_tags,
    {
      Name                                = "${var.name}-etcd-${count.index}"
      Role                                = "etcd"
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )
}

resource "aws_volume_attachment" "etcd" {
  count       = var.instance_config["count"]
  device_name = var.instance_config["data_device_name"]
  volume_id   = aws_ebs_volume.etcd[count.index].id
  instance_id = aws_instance.etcd[count.index].id
}

resource "aws_instance" "etcd" {
  count = var.instance_config["count"]

  ami                  = var.instance_config["image_id"]
  instance_type        = var.instance_config["ec2_type"]
  key_name             = var.ssh_key
  iam_instance_profile = aws_iam_instance_profile.etcd.id

  user_data = data.ignition_config.s3.rendered

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.etcd[count.index].id
  }

  root_block_device {
    volume_size = var.instance_config["root_volume_size"]
    volume_type = var.instance_volume_config.root.type
    iops        = lookup(local.iops_by_type.root, var.instance_volume_config.root.type, null)
    throughput  = lookup(local.throughput_by_type.root, var.instance_volume_config.root.type, null)
  }

  volume_tags = merge(var.extra_tags,
    {
      Name                                = "${var.name}-etcd-${count.index}"
      Role                                = "etcd"
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )

  tags = merge(var.extra_tags,
    {
      Name                                = "${var.name}-etcd-${count.index}"
      Role                                = "etcd"
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )

  lifecycle {
    # Ignore changes in the ami & userdata which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [ami, user_data]
  }
}
