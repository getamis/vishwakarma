terraform {
  required_version = ">= 0.13.1"

  required_providers {
    ignition = {
      source  = "terraform-providers/ignition"
      version = "~> 1.2.1"
    }
  }
}