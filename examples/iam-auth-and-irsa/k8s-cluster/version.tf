terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = var.aws_region
}
