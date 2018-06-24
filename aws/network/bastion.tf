resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.new_vpc.id}"

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-bastion",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

data "aws_ami" "latest_ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical

}

resource "random_integer" "subnet_id_index" {
  min     = 0
  max     = "${var.aws_az_number - 1}"

  keepers = {
    vpc_id = "${aws_vpc.new_vpc.id}"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${var.bastion_ami_id == "" ? data.aws_ami.latest_ubuntu.image_id : var.bastion_ami_id}"
  associate_public_ip_address = true
  instance_type               = "${var.bastion_instance_type}"
  key_name                    = "${var.bastion_key_name}"
  source_dest_check           = true
  subnet_id                   = "${aws_subnet.public_subnet.*.id[random_integer.subnet_id_index.result]}"

  root_block_device {
    volume_type = "standard"
    volume_size = "40"
  }

  vpc_security_group_ids = [
    "${ aws_security_group.bastion.id }",
  ]

  tags = "${merge(map(
      "Name", "${var.phase}-${var.project}-bastion",
      "Phase", "${var.phase}",
      "Project", "${var.project}"
    ), var.extra_tags)}"
}
