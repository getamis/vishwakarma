resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(map(
    "Name", "${var.phase}-${var.project}-bastion",
    "Phase", var.phase,
    "Project", var.project
  ), var.extra_tags)
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.bastion.id

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

data "template_file" "user_data" {
  template = file("${path.module}/resources/user_data")
}

module "latest_os_ami" {
  source  = "../../aws/latest-os-ami"
  os_name = "ubuntu"
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id == "" ? module.latest_os_ami.image_id : var.bastion_ami_id
  associate_public_ip_address = true
  instance_type               = var.bastion_instance_type
  key_name                    = var.bastion_key_name
  source_dest_check           = true
  subnet_id                   = aws_subnet.public_subnet.*.id[0]
  user_data                   = data.template_file.user_data.rendered

  root_block_device {
    volume_type = "standard"
    volume_size = "40"
  }

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  tags = merge(map(
    "Name", "${var.phase}-${var.project}-bastion",
    "Phase", var.phase,
    "Project", var.project
  ), var.extra_tags)
}
