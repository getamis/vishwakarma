locals {
  mask = var.reboot_strategy == "off" ? true : false
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = local.mask
}
