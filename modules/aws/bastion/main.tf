resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id

  tags = merge(var.extra_tags,
    {
      Name = "${var.name}-bastion",
      Role = "bastion"
    }
  )
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

module "os_ami" {
  source = "../../aws/os-ami"
  flavor = "ubuntu"
}

data "aws_iam_policy_document" "bastion_profile" {
  statement {
    sid = "BastionAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name_prefix        = "${var.name}-bastion-"
  assume_role_policy = data.aws_iam_policy_document.bastion_profile.json
}

resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${var.name}-bastion-"
  role        = aws_iam_role.bastion.name
}

data "aws_iam_policy_document" "bastion" {
  statement {
    sid = "IAM"
    actions = [
      "iam:*",
      "organizations:DescribeAccount",
      "organizations:DescribeOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:DescribePolicy",
      "organizations:ListChildren",
      "organizations:ListParents",
      "organizations:ListPoliciesForTarget",
      "organizations:ListRoots",
      "organizations:ListPolicies",
      "organizations:ListTargetsForPolicy"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "S3"
    actions = [
      "s3:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "STS"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "bastion" {
  name        = "${var.name}-bastion"
  path        = "/"
  description = "policy for bastion"
  policy      = data.aws_iam_policy_document.bastion.json
}

resource "aws_iam_role_policy_attachment" "bastion" {
  policy_arn = aws_iam_policy.bastion.arn
  role       = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id == "" ? module.os_ami.image_id : var.ami_id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  key_name                    = var.key_name
  source_dest_check           = true
  subnet_id                   = var.subnet_id
  user_data                   = data.template_file.user_data.rendered

  root_block_device {
    volume_type = "standard"
    volume_size = "40"
  }

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  tags = merge(var.extra_tags,
    {
      Name = "${var.name}-bastion",
      Role = "bastion"
    }
  )
}
