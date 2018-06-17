# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt

terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket

  # Configure root level variables that all resources can inherit
  terraform {
    extra_arguments "bucket" {
      commands = ["${get_terraform_commands_that_need_vars()}"]

      arguments = [
        "-var", "aws_region=us-east-1"
      ]
    }
  }
}
