variable "ntp_servers" {
  description = "A list of NTP servers to be used for time synchronization on the cluster nodes."
  type        = list(string)
}
