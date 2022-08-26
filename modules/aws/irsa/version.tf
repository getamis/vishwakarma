terraform {
  required_version = ">= 1.2.0"

  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "2.1.2"
    }
  }
}