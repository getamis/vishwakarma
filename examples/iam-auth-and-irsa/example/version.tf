terraform {
  required_version = "~> 0.12.29"
}

provider "aws" {
  region  = var.aws_region
  version = "~>v3.59.0"
}

provider "local" {
  version = "1.4.0"
}


