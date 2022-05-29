locals {
  defaults = {
    label_order = [
      "Environment",
      "Project",
      "Name",
      "Service",
      "Role",
      "Language",
      "BuiltWith",
      "CreatedBy",
      "Attributes"
    ]
    delimiter   = "-"
    replacement = ""
    # The `sentinel` should match the `regex_replace_chars`, so it will be replaced with the `replacement` value
    sentinel   = "~"
    attributes = [""]
  }

  # The values provided by variables superceed the values inherited from the context

  enabled             = var.enabled
  regex_replace_chars = coalesce(var.regex_replace_chars, var.context.regex_replace_chars)

  environment = lower(replace(coalesce(var.environment, var.context.Environment, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  project     = lower(replace(coalesce(var.project, var.context.Project, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  service     = lower(replace(coalesce(var.service, var.context.Service, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  role        = lower(replace(coalesce(var.role, var.context.Role, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  language    = lower(replace(coalesce(var.language, var.context.Language, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  built_with  = lower(replace(coalesce(var.built_with, var.context.BuiltWith, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  created_by  = lower(replace(coalesce(var.created_by, var.context.CreatedBy, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))

  delimiter          = coalesce(var.delimiter, var.context.delimiter, local.defaults.delimiter)
  label_order        = length(var.label_order) > 0 ? var.label_order : (length(var.context.label_order) > 0 ? var.context.label_order : local.defaults.label_order)
  additional_tag_map = merge(var.context.additional_tag_map, var.additional_tag_map)

  # Merge attributes
  attributes = compact(distinct(concat(var.attributes, var.context.attributes, local.defaults.attributes)))

  tags = merge(var.context.tags, local.generated_tags, var.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, var.additional_tag_map)
  ])

  tags_context = {
    # For AWS we need `Name` to be disambiguated sine it has a special meaning
    Environment = local.environment
    Project     = local.project
    Name        = local.id
    Service     = local.service
    Role        = local.role
    Language    = local.language
    BuiltWith   = local.built_with
    CreatedBy   = local.created_by
    Attributes  = local.attributes
  }

  generated_tags = { for l in keys(local.tags_context) : title(l) => local.tags_context[l] if length(local.tags_context[l]) > 0 }

  id = lower(join(local.delimiter, [local.environment, local.project, var.name]))
}

