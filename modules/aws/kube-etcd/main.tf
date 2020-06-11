data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "etcd" {
  count = var.etcd_config["instance_count"]
  id    = var.subnet_ids[count.index]
}

locals {
  vpc_id       = data.aws_subnet.etcd[0].vpc_id
  az_num       = length(data.aws_availability_zones.available.names)
  client_port  = 2379
  peer_port    = 2380
}

module "latest_os_ami" {
  source  = "../../aws/latest-os-ami"
  os_name = "coreos"
}

resource "aws_network_interface" "etcd" {
  count             = var.etcd_config["instance_count"]
  subnet_id         = var.subnet_ids[count.index]
  security_groups   = compact(concat(
    var.security_group_ids,
    list(aws_security_group.etcd.id)
  ))
  source_dest_check = false

  tags = merge(map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_ebs_volume" "etcd" {
  count             = var.etcd_config["instance_count"]
  availability_zone = data.aws_subnet.etcd[count.index].availability_zone
  size              = var.etcd_config["data_volume_size"]

  tags = merge(map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}

resource "aws_volume_attachment" "etcd" {
  count       = var.etcd_config["instance_count"]
  device_name = var.etcd_config["data_device_name"]
  volume_id   = aws_ebs_volume.etcd[count.index].id
  instance_id = aws_instance.etcd[count.index].id
}

resource "aws_instance" "etcd" {
  count = var.etcd_config["instance_count"]

  ami                  = module.latest_os_ami.image_id
  instance_type        = var.etcd_config["ec2_type"]
  key_name             = var.ssh_key
  iam_instance_profile = aws_iam_instance_profile.etcd.id

  user_data = data.ignition_config.s3.rendered

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.etcd[count.index].id
  }

  root_block_device {
    volume_size = var.etcd_config["root_volume_size"]
  }

  volume_tags = merge(map(
    "Name", "${var.name}-etcd-root-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)

  tags = merge(map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [ami]
  }
}
