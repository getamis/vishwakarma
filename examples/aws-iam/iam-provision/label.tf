# ---------------------------------------------------------------------------------------------------------------------
# Naming and Tags
# ---------------------------------------------------------------------------------------------------------------------

module "label" {
  source      = "../../../modules/aws/null-label"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}