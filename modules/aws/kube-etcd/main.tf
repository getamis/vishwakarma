locals {
  vpc_id       = data.aws_subnet.etcd[0].vpc_id
  az_num       = length(data.aws_availability_zones.available.names)
  client_port  = 2379
  peer_port    = 2380
  node_exporter_port = 9100
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "etcd" {
  count = local.instance_config["count"]
  id    = var.subnet_ids[count.index % length(var.subnet_ids)]
}

module "latest_os_ami" {
  source  = "../../aws/latest-os-ami"
  os_name = "coreos"
}

resource "aws_network_interface" "etcd" {
  count             = local.instance_config["count"]
  subnet_id         = var.subnet_ids[count.index % length(var.subnet_ids)]
  security_groups   = compact(concat(
    var.security_group_ids,
    list(aws_security_group.etcd.id)
  ))
  source_dest_check = false

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "etcd"
  ))
}

resource "aws_ebs_volume" "etcd" {
  count             = local.instance_config["count"]
  availability_zone = data.aws_subnet.etcd[count.index].availability_zone
  size              = local.instance_config["data_volume_size"]

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "ectd"
  ))
}

resource "aws_volume_attachment" "etcd" {
  count       = local.instance_config["count"]
  device_name = local.instance_config["data_device_name"]
  volume_id   = aws_ebs_volume.etcd[count.index].id
  instance_id = aws_instance.etcd[count.index].id
}

resource "aws_instance" "etcd" {
  count = local.instance_config["count"]

  ami                  = module.latest_os_ami.image_id
  instance_type        = local.instance_config["ec2_type"]
  key_name             = var.ssh_key
  iam_instance_profile = aws_iam_instance_profile.etcd.id

  user_data = data.ignition_config.s3.rendered

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.etcd[count.index].id
  }

  root_block_device {
    volume_size = local.instance_config["root_volume_size"]
  }

  volume_tags = merge(var.extra_tags, map(
    "Name", "${var.name}-etcd-root-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "etcd"
  ))

  tags = merge(var.extra_tags, map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "etcd"
  ))

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [ami]
  }
}
