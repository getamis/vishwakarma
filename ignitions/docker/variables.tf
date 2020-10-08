variable "docker_opts" {
  type        = "list"
  description = "See official docker documentation and https://coreos.com/os/docs/latest/customizing-docker.html for details."

  default = [
    "--log-opt",
    "max-size=50m",
    "--log-opt",
    "max-file=3",
    "--experimental"
  ]
}
