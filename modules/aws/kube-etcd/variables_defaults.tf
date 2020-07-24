locals {
  instance_config = merge({
    count              = "1"
    ec2_type           = "t3.medium"
    root_volume_size   = "40"
    data_volume_size   = "100"
    data_device_name   = "/dev/sdf"
    data_device_rename = "/dev/nvme1n1"
    data_path          = "/etcd/data"

    // CoreOS Container Linux stable 2512.3.0
    image_id = "ami-0c45c2b94700c3e25"
  }, var.instance_config)
}
