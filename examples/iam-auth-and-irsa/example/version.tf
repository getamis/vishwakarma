terraform {
  required_version = "~> 0.12.29"
}

provider "aws" {
  region  = var.aws_region
  version = "~>3.13.0"
}

provider "local" {
  version = "1.4.0"
}


