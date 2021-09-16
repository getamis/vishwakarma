terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 2.1"
    }
  }
}