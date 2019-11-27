variable "docker_opts" {
  description = "See official docker documentation and https://coreos.com/os/docs/latest/customizing-docker.html for details."
  type        = list(string)
  default     = [
    "--log-opt",
    "max-size=50m",
    "--log-opt",
    "max-file=3",
    "--live-restore",
    "--max-concurrent-downloads=10"
  ]
}
