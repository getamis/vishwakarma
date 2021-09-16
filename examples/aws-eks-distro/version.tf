terraform {
  required_version = "~> 1.0.0"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 3.57.0"
}

provider "external" {
  version = "2.1.0"
}

provider "null" {
  version = "3.1.0"
}

provider "random" {
  version = "3.1.0"
}

provider "tls" {
  version = "3.1.0"
}
