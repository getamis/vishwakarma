data "ignition_file" "aws_iam_auth_key_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${var.state_path}/key.pem"

  content {
    content = var.aws_iam_auth_key_pem
  }
}

data "ignition_file" "aws_iam_auth_cert_pem" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${var.state_path}/cert.pem"

  content {
    content = var.aws_iam_auth_crt_pem
  }
}
