variable "release_channel" {
  description = <<EOF
The Container Linux update channel.

Examples: `stable`, `beta`, `alpha`
EOF
  type        = string
}

variable "release_version" {
  description = <<EOF
The Container Linux version to use. Set to `latest` to select the latest available version for the selected update channel.

Examples: `latest`, `1465.6.0`
EOF
  type        = string
}
