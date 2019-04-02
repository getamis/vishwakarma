# Variables
## aws/network

### inputs
| Name                      | Description                                                                                                                                                                                                              |  Type  | Default  | Required |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----: | :------: | :------: |
| aws_region              | The AWS region to build network infrastructure                                                                                                                                            | string |    -     |   yes    |
| aws_az_number           | How many available zone want to be used                                                                                                                                            | string |    3     |   no    |
| cidr_block              | The CIDR block for AWS VPC                                                                                                                                            | string |    10.0.0.0/16     |   no    |
| phase                   | Specific which phase service will be hosted                                                                                                                                           | string |       dev       |   no    |
| project                   | Specific which project service will be hosted                                                                                                                                            | string |   vishwakarma   |   no    |
| bastion_ami_id          | The AWS AMI id for bastion, if that isn't provided, ubuntu latest ami will be used                                                                                                                                            | string |    ""           |   no    |
| bastion_instance_type   | The AWS instance type for bastion                                                                                                                                            | string |    t2.micro     |   no    |
| bastion_key_name        | The AWS EC2 key name for bastion                                                                                                                                            | string |    -     |   yes    |
| private_zone        | The AWS EC2 key name for bastion                                                                                                                                            | string |    false     |   no    |
| extra_tags        | Create a private Route53 host zone                                                                                                                                            | map |    {}     |   no    |


### outputs

## aws/eks

### inputs
| Name                      | Description                                                                                                                                                                                                              |  Type  | Default  | Required |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----: | :------: | :------: |
| aws_region              | The AWS region to build eks cluster                                                                                                                                            | string |    -     |   yes    |
| vpc_cidr_block          | The CIDR block of AWS VPC for eks cluster                                                                                                                                           | string |    10.0.0.0/16     |   no    |
| exist_vpc_id            | The exist AWS VPC id for EKS cluster                                                                                                                                           | string |    -     |   yes    |
| exist_subnet_ids            | The exist AWS subnet ids for EKS cluster                                                                                                                                           | list |    -     |   yes    |
| phase                   | Specific which phase is used for this eks cluster, and phase + project become cluster name                                                                                                                                           | string |       dev       |   no    |
| project                   | Specific which project is used by eks cluster, and phase + project become cluster name                                                                                                                                            | string |   vishwakarma   |   no    |
| config_output_path            | The path to store config, e.g. kubeconfig                                                                                                                                           | string |    .terraform     |   no    |
| lb_sg_ids            | The security group id which used by load balancer                                                                                                                                           | list |    []     |   no    |
| extra_tags        | The AWS EC2 key name for bastion                                                                                                                                            | map |    {}     |   no    |


### outputs

## aws/eks-worker

### inputs
| Name                      | Description                                                                                                                                                                                                              |  Type  | Default  | Required |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----: | :------: | :------: |
| phase                   | Specific which phase is used for this eks worker node group                                                                                                                                           | string |       dev       |   no    |
| project                   | Specific which project is used for this eks worker node group                                                                                                                                            | string |   vishwakarma   |   no    |
| project                   | Specific which project is used for this eks worker node group                                                                                                                                            | string |   vishwakarma   |   no    |
| ssh_key              | The ssh key name for worker node instance                                                                                                                                            | string |    -     |   yes    |
| aws_region              | The AWS region to host this eks worker node group                                                                                                                                            | string |    -     |   yes    |
| vpc_id              | The vpc id to host this eks worker ndoe group                                                                                                                                            | string |    -     |   yes    |
| aws_az_number       | How many AZs want to use                                                                                                                                            | string |    3     |   no    |
| container_linux_channel       | CoreOS release channel for worker node                                                                                                                                           | string |    stable     |   no    |
| container_linux_version       | CoreOS release version for worker node                                                                                                                                          | string |    latest     |   no    |
| cluster_name       | The eks cluster name                                                                                                                                          | string |   -     |   yes    |
| cluster_endpoint       | The eks cluster endpoint                                                                                                                                          | string |   -     |   yes    |
| certificate_authority_data       | The eks cluster certificate authority data                                                                                                                                          | string |   -     |   yes    |
| worker_name       | The name for worker node                                                                                                                                          | string |   -     |   yes    |
| ec2_type       | The ec2 type for worker node                                                                                                                                          | string |   -     |   yes    |
| ec2_ami       | The ami for worker node                                                                                                                                          | string |   ""     |   no    |
| instance_count       | The minimal worker node number                                                                                                                                          | string |   1     |   no    |
| subnet_ids       | The subnet ids for worker node to host                                                                                                                                          | list |   -     |   yes    |
| sg_ids       | The security group IDs to be applied for work node                                                                                                                                          | list |   -     |   yes    |
| load_balancers       | List of ELBs to attach all worker instances to                                                                                                                                          | list |   []     |   no    |
| target_group_arns       | List of target groups arn to attach all worker instances to                                                                                                                                          | list |   []     |   no    |
| container_images       | Container images to use                                                                                                                                          | map |   -     |   yes    |
| bootstrap_upgrade_cl       |  Whether to trigger a Container Linux OS upgrade during the bootstrap process                                                                                                                                          | string |   true     |   no    |
| ntp_servers       |  A list of NTP servers to be used for time synchronization on the cluster nodes                                                                                                                                          | list |   []     |   no    |
| kubelet_node_label       |  A list of NTP servers to be used for time synchronization on the cluster nodes                                                                                                                                          | string |   ""     |   no    |
| cloud_provider       |  The cloud provider to be used for the kubelet                                                                                                                                          | string |   aws     |   no    |
| image_re       |  Regular expression used to extract repo and tag components from image strings                                                                                                                                          | string |   /^([^/]+/[^/]+/[^/]+):(.*)$/     |   no    |
| client_ca_file       |  The eks cercificate file path                                                                                                                                          | string |   /etc/kubernetes/pki/ca.crt     |   no    |
| heptio_authenticator_aws_url       |  heptio authenticator aws download url                                                                                                                                          | string |   https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws     |   no    |
| extra_tags       |  Extra AWS tags to be applied to created resources                                                                                                                                          | map |   {}     |   no    |
| root_volume_type       |  The type of volume for the root block device                                                                                                                                          | string |   gp2     |   no    |
| root_volume_size       |  The size of the volume in gigabytes for the root block device                                                                                                                                          | string |   200     |   no    |
| root_volume_iops       |  The amount of provisioned IOPS for the root block device                                                                                                                                          | string |   100     |   no    |
| worker_iam_role       |  Exist IAM role to use for the instance profiles of worker nodes                                                                                                                                          | string |   ""     |   no    |
| s3_bucket       |  The s3 bucket to store ignition file for EC2 userdata                                                                                                                                          | string |   -     |   yes    |


### outputs

## aws/elastikube

### input

### output

## aws/kube-worker

### input

### output