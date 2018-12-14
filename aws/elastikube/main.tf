provider "aws" {
  version = "1.51.0"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "1.0.0"
}

provider "ignition" {
  version = "~>1.0"
}

locals {
  cluster_dns_ip = "${cidrhost(var.service_cidr, 10)}"
}
