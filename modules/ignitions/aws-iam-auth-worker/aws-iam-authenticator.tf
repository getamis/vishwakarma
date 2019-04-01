data "template_file" "aws_iam_authenticator" {
  template = "${file("${path.module}/resources/services/aws-iam-authenticator.service")}"

  vars {
    aws_iam_authenticator_url = "${var.aws_iam_authenticator_url}"
  }
}

data "ignition_systemd_unit" "aws_iam_authenticator" {
  name    = "aws-iam-authenticator.service"
  enabled = true
  content = "${data.template_file.aws_iam_authenticator.rendered}"
}