output "id" {
  description = "Disambiguated ID"
  value       = local.enabled ? local.id : ""
}

output "built_with" {
  description = "Normalized built_with"
  value       = local.enabled ? local.built_with : ""
}

output "created_by" {
  description = "Normalized created_by"
  value       = local.enabled ? local.created_by : ""
}

output "environment" {
  description = "Normalized environment"
  value       = local.enabled ? local.environment : ""
}

output "language" {
  description = "Normalized language"
  value       = local.enabled ? local.language : ""
}

output "project" {
  description = "Normalized project"
  value       = local.enabled ? local.project : ""
}

output "service" {
  description = "Normalized service"
  value       = local.enabled ? local.service : ""
}

output "attributes" {
  description = "List of attributes"
  value       = local.enabled ? local.attributes : []
}

output "delimiter" {
  description = "Delimiter between `namespace`, `environment`, `stage`, `name` and `attributes`"
  value       = local.enabled ? local.delimiter : ""
}

output "tags" {
  description = "Normalized Tag map"
  value       = local.enabled ? local.tags : {}
}

output "tags_as_list_of_maps" {
  description = "Additional tags as a list of maps, which can be used in several AWS resources"
  value       = local.tags_as_list_of_maps
}

output "label_order" {
  description = "The naming order of the id output and Name tag"
  value       = local.label_order
}
