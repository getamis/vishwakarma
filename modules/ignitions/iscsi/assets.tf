data "ignition_systemd_unit" "iscsi" {
  name    = "iscsid.service"
  enabled = var.enabled ? true : false
}
