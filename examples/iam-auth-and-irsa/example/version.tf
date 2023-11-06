terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "2.1.2"
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


