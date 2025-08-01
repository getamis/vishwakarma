terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "2.1.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
