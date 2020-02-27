data "aws_subnet" "etcd" {
  count = var.etcd_config["instance_count"]
  id    = var.subnet_ids[count.index % length(var.subnet_ids)]
}

locals {
  vpc_id      = data.aws_subnet.etcd[0].vpc_id
  client_port = 2379
  peer_port   = 2380
}

module "latest_os_ami" {
  source = "../../aws/latest-os-ami"
}

resource "aws_instance" "etcd" {
  count = var.etcd_config["instance_count"]

  ami                  = module.latest_os_ami.fedora_coreos_image_id
  instance_type        = var.etcd_config["ec2_type"]
  key_name             = var.ssh_key
  iam_instance_profile = aws_iam_instance_profile.etcd.id
  subnet_id            = var.subnet_ids[count.index % length(var.subnet_ids)]

  vpc_security_group_ids = compact(concat(
    var.security_group_ids,
    list(aws_security_group.etcd.id)
  ))

  user_data = data.ignition_config.s3.rendered

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [ami]
  }

  tags = merge(map(
    "Name", "${var.name}-etcd-${count.index}",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)

  root_block_device {
    volume_type = var.etcd_config["root_volume_type"]
    volume_size = var.etcd_config["root_volume_size"]
    iops        = var.etcd_config["root_volume_type"] == "io1" ? var.etcd_config["root_volume_iops"] : var.etcd_config["root_volume_type"] == "gp2" ? min(10000, max(100, 3 * var.etcd_config["root_volume_size"])) : 0
  }

  volume_tags = merge(map(
    "Name", "${var.name}-etcd-${count.index}-vol",
    "kubernetes.io/cluster/${var.name}", "owned",
  ), var.extra_tags)
}
