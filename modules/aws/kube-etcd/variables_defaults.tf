locals {
  instance_config = merge({
    count              = "1"
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"
  }, var.instance_config)
}
