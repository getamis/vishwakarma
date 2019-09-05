locals {
  eks_account_id = "602401143452"
  arn            = "aws"
}

data "aws_ami" "eks_worker_ami" {

  owners      = [local.eks_account_id]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
