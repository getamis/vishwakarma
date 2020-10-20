variable "flavor" {
  description = "Name of the operating system.(ex: 'flatcar', 'fedora_coreos' and 'ubuntu')."
  type        = string
}

variable "most_recent" {
  description = " (Optional) If more than one result is returned, use the most recent AMI."
  type        = bool
  default     = true
}

variable "channel" {
  type        = string
  description = "AMI channel for Flatcar Container Linux derivative ('stable', 'beta', 'alpha' and 'edge')."
  default     = "stable"
}

variable "flatcar_version" {
  type        = string
  description = "Version for Flatcar Container Linux derivative."
  default     = "*"
}

variable "channel_version" {
  type        = string
  description = "AMI channel for a Fedora CoreOS derivative (1.0 = next, 2.0 = testing, 3.0 = stable)."
  default     = "3.0"
}
