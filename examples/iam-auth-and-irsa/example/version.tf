terraform {
  required_version = ">= 0.13.1"

  required_providers {
    ignition = {
      source  = "terraform-providers/ignition"
      version = "~> 1.2.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.16.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


