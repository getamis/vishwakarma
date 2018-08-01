data "aws_iam_policy_document" "default" {
  statement {
    sid = "KubeMasterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "master" {
  name_prefix        = "${var.name}-master-"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_instance_profile" "master" {
  name = "${var.name}-master"

  role = "${var.role_name == "" ?
    join("|", aws_iam_role.master.*.name) :
    var.role_name
  }"
}

resource "aws_iam_policy" "master" {
  count       = "${var.role_name == "" ? 1 : 0}"
  name        = "${var.name}-master"
  path        = "/"
  description = "policy for kubernetes masters"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket}/*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "master" {
  policy_arn = "${aws_iam_policy.master.arn}"
  role       = "${aws_iam_role.master.name}"
}

# Role for Spot Fleet
resource "aws_iam_role" "spot_fleet_tagging" {
  name = "${var.name}-spot-fleet-tagging"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "spot_fleet_tagging" {
  role       = "${aws_iam_role.spot_fleet_tagging.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}


resource "aws_iam_role" "spot_fleet_autoscale" {
  name = "${var.name}-spot-fleet-autoscale"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "spot_fleet_autoscale" {
  count      = "${var.role_name == "" ? 1 : 0}"
  role       = "${aws_iam_role.spot_fleet_autoscale.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetAutoscaleRole"
}
