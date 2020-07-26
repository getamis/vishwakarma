locals {
  instance_config = merge({
    count            = "1"
    ec2_type_1       = "t3.medium"
    ec2_type_2       = "t2.medium"
    root_volume_iops = "100"
    root_volume_size = "256"
    root_volume_type = "gp2"

    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 1

    // CoreOS Container Linux stable 2512.3.0
    image_id = "ami-0c45c2b94700c3e25"
  }, var.instance_config)
}
