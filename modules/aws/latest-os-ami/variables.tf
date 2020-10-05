variable "flavor" {
  description = "Name of the operating system.(ex: 'flatcar', 'fedora_coreos' and 'ubuntu')"
  type        = string
}

variable "channel" {
  type        = string
  description = "AMI channel for Flatcar Container Linux derivative ('stable', 'beta', 'alpha' and 'edge')"
  default     = "stable"
}

variable "channel_version" {
  type        = string
  description = "AMI channel for a Fedora CoreOS derivative (1.0 = next, 2.0 = testing, 3.0 = stable)"
  default     = "3.0"
}
