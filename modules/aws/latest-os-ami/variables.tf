variable "flavor" {
  description = "Name of the operating system.(ex: 'coreos', 'flatcar', 'fedora_coreos', 'ubuntu')"
  type        = string
}

variable "channel" {
  type        = string
  description = "AMI channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, flatcar-alpha, flatcar-edge)"
  default     = "stable"
}

variable "channel_version" {
  type        = string
  description = "AMI channel for a Fedora CoreOS derivative (1.0 = next, 2.0 = testing, 3.0 = stable)"
  default     = "3.0"
}
