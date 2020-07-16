data "ignition_filesystem" "ectd_data" {
  name = "etcd-data"

  mount {
    device = var.device_name
    format = "ext4"
  }
}

data "ignition_disk" "ectd_data" {
  device = var.device_name

  partition {
    number = 1
    start  = 0
    size   = 0
  }
}

data "template_file" "etcd_data_mount" {
  template = file("${path.module}/templates/data.mount.tpl")

  vars = {
    device_name = var.device_name
    data_path   = "/etcd"
  }
}

data "ignition_systemd_unit" "etcd_data_mount" {
  content = data.template_file.etcd_data_mount.rendered
  name    = "etcd.mount"
}