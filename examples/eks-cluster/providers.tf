terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region  = var.aws_region
  version = "2.43.0"
}

provider "external" {
  version = "1.2.0"
}

provider "local" {
  version = "1.3.0"
}

provider "null" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.0"
}

provider "template" {
  version = "2.1.2"
}
