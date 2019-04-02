# ---------------------------------------------------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "2.3.0"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "1.0.0"
}

provider "null" {
  version = "1.0.0"
}


data "aws_eks_cluster" "vishwakarma" {
  name = "${var.cluster_name}"
}