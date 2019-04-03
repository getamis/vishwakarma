# Variables
## aws/network

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_az\_number | How many AZs want to be used | string | `"3"` | no |
| aws\_region | The AWS region to build network infrastructure | string | n/a | yes |
| bastion\_ami\_id | The AWS AMI id for bastion | string | `""` | no |
| bastion\_instance\_type | The AWS instance type for bastion | string | `"t3.micro"` | no |
| bastion\_key\_name | The AWS EC2 key name for bastion | string | n/a | yes |
| cidr\_block | The CIDR block for AWS VPC | string | `"10.0.0.0/16"` | no |
| extra\_tags | Extra AWS tags to be applied to created resources | map | `<map>` | no |
| phase | Specific which phase service will be hosted | string | `"test"` | no |
| private\_zone | Create a private Route53 host zone | string | `"false"` | no |
| project | Specific which project service will host | string | `"vishwakarma"` | no |

### Outputs

| Name | Description |
|------|-------------|
| bastion\_public\_ip | the public ip address for ssh |
| private\_subnet\_ids | resource can not be accessed publicly when use it |
| public\_subnet\_ids | resource can be accessed publicly when use it |
| vpc\_id | vpc id created by this module |
| zone\_id | private zone id for k8s |

## aws/eks

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_auth\_config\_output\_flag | Whether to write the aws-auth configmap file. | string | `"true"` | no |
| aws\_region | The AWS region to build eks cluster | string | `""` | no |
| cidr\_access\_eks\_https | The CIDR block of AWS VPC for eks cluster | list | `<list>` | no |
| cidr\_access\_worker\_ssh | The CIDR block of AWS VPC for eks cluster | list | `<list>` | no |
| config\_output\_path | The path to store config, e.g. kubeconfig | string | `"./terraform"` | no |
| endpoint\_private\_access | Kubernetes apiserver endpoint | string | `"true"` | no |
| endpoint\_public\_access | Kubernetes apiserver endpoint | string | `"false"` | no |
| exist\_subnet\_ids | The exist AWS subnet ids for EKS cluster | list | n/a | yes |
| extra\_tags | Extra AWS tags to be applied to created resources. | map | `<map>` | no |
| iam\_path | If provided, all IAM roles will be created on this path. | string | `"/"` | no |
| kubeconfig\_aws\_authenticator\_additional\_args | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | list | `<list>` | no |
| kubeconfig\_aws\_authenticator\_command | Command to use to fetch AWS EKS credentials. | string | `"aws-iam-authenticator"` | no |
| kubeconfig\_aws\_authenticator\_command\_args | Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]. | list | `<list>` | no |
| kubeconfig\_aws\_authenticator\_env\_variables | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = "eks"}. | map | `<map>` | no |
| kubeconfig\_name | Override the default name used for items kubeconfig. | string | `""` | no |
| kubeconfig\_output\_flag | Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`. | string | `"true"` | no |
| kubernetes\_version | Desired Kubernetes master version. If you do not specify a value, the latest available version is used. | string | `"1.12.7"` | no |
| lb\_sg\_ids | The security group id which used by load balancer | list | `<list>` | no |
| local\_exec\_interpreter | Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice. | list | `<list>` | no |
| manage\_aws\_auth | Whether to apply the aws-auth configmap file. | string | `"true"` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_accounts\_count | The count of accounts in the map_accounts list. | string | `"0"` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_roles\_count | The count of roles in the map_roles list. | string | `"0"` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map\_users\_count | The count of roles in the map_users list. | string | `"0"` | no |
| permissions\_boundary | If provided, all IAM roles will be created with this permissions boundary attached. | string | `""` | no |
| phase | Specific which phase is used for this eks cluster, and phase + project become cluster name | string | `"test"` | no |
| project | Specific which project is used by eks cluster, and phase + project become cluster name | string | `"vishwakarma"` | no |
| worker\_groups | The worker groups's name for generating role | list | `<list>` | no |

### Outputs

| Name | Description |
|------|-------------|
| endpoint | the eks cluster endpoint |
| id | the eks cluster name |
| kubernetes\_version | the eks cluster version |
| s3\_bucket | the s3 bucket where put kubeconfig |
| worker\_instance\_profiles | the instance profiles name for worker groups |
| worker\_role\_arns | the role arns for worker groups |
| worker\_sg\_id | the security group id for worker group |

## aws/eks-worker

### inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_az\_number | How many AZs want to use | string | `"3"` | no |
| aws\_region | The AWS region | string | `"us-west-2"` | no |
| cluster\_name | the eks cluster name | string | n/a | yes |
| enable\_autoscaler | enable autoscaler or not | string | `"false"` | no |
| extra\_tags | Extra AWS tags to be applied to created resources. | map | `<map>` | no |
| extra\_worker\_policy\_arns | The extra policy need to be attached to worker | list | `<list>` | no |
| kube\_node\_labels | Labels to add when registering the node in the cluster. Labels must be key=value pairs. | list | `<list>` | no |
| kube\_node\_taints | Register the node with the given list of taints ("<key>=<value>:<effect>"). | list | `<list>` | no |
| load\_balancer\_ids | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead. | list | `<list>` | no |
| security\_group\_ids | List of security group IDs for the cross-account elastic network interfaces     to use to allow communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| ssh\_key | The key name that should be used for the instance. | string | `""` | no |
| subnet\_ids | List of subnet IDs. Must be in at least two different availability zones.     Cross-account elastic network interfaces will be created in these subnets to allow     communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| target\_group\_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing. | list | `<list>` | no |
| worker\_config | Desired worker nodes configuration. | map | `<map>` | no |

## aws/elastikube

### input
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_ssh\_cidr | (Optional) A list of CIDR networks to allow ssh access to. Defaults to "0.0.0.0/0" | list | `<list>` | no |
| audit\_log\_backend | (Optional) Kubernetes apiserver auditing log backend configuration,     there are four parameters: path, maxage, maxbackup, maxsize. | map | `<map>` | no |
| audit\_policy\_path | (Optional) A policy path for Kubernetes apiserver to enable auditing log. | string | `""` | no |
| auth\_webhook\_path | (Optional) A path for using customize machine to authenticate to a Kubernetes cluster. | string | `""` | no |
| aws\_region | (Optional) The AWS region | string | `"us-east-1"` | no |
| cluster\_cidr | (Optional) The Kubernetes cluster CIDR. | string | `"172.24.0.0/13"` | no |
| endpoint\_public\_access | (Optional) kubernetes apiserver endpoint | string | `"false"` | no |
| etcd\_config | (Optional) Desired etcd nodes configuration. | map | `<map>` | no |
| extra\_etcd\_ignition\_file\_ids | (Optional) Additional ignition file IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details. | list | `<list>` | no |
| extra\_etcd\_ignition\_systemd\_unit\_ids | (Optional) Additional ignition systemd unit IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details. | list | `<list>` | no |
| extra\_ignition\_file\_ids | (Optional) Additional ignition file IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details. | list | `<list>` | no |
| extra\_ignition\_systemd\_unit\_ids | (Optional) Additional ignition systemd unit IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details. | list | `<list>` | no |
| extra\_master\_node\_labels | (Optional) Labels to add when registering the node in the cluster. Labels must be key=value pairs. | list | `<list>` | no |
| extra\_master\_node\_taints | (Optional) Register the node with the given list of taints ("<key>=<value>:<effect>"). | list | `<list>` | no |
| extra\_tags | (Optional) Extra AWS tags to be applied to the resources. | map | `<map>` | no |
| hostzone | (Optional) The cluster private hostname. If not specified, <cluster name>.com will be used. | string | `""` | no |
| kubelet\_flag\_extra\_flags | Extra user-provided flags to kubelet. | list | `<list>` | no |
| kubernetes\_version | (Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used. | string | `"v1.13.4"` | no |
| lb\_security\_group\_ids | (Optional) List of security group IDs for the cross-account elastic network interfaces     to use to allow communication to the kubernetes api server load balancer. | list | `<list>` | no |
| master\_config | (Optional) Desired master nodes configuration. | map | `<map>` | no |
| name | (Required) Name of the cluster. | string | n/a | yes |
| private\_subnet\_ids | (Required) List of private subnet IDs. Must be in at least two different availability zones.     Cross-account elastic network interfaces will be created in these subnets to allow     communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| public\_subnet\_ids | (Required) List of public subnet IDs. Must be in at least two different availability zones.     Cross-account elastic network interfaces will be created in these subnets to allow     communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| reboot\_strategy | (Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off | string | `"off"` | no |
| role\_name | (Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. | string | `""` | no |
| security\_group\_ids | (Optional) List of security group IDs for the cross-account elastic network interfaces     to use to allow communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| service\_cidr | (Optional) The Kubernetes service CIDR. | string | `"172.16.0.0/13"` | no |
| ssh\_key | The key name that should be used for the instances. | string | `""` | no |

### output
| Name | Description |
|------|-------------|
| certificate\_authority | K8S root CA Cert |
| endpoint | K8S cluster endpoint |
| id | K8S cluster name |
| master\_sg\_ids | The security group which used by K8S master |
| s3\_bucket | The S3 bucket for storing provision ignition file |
| version | K8S cluster version |
| vpc\_id | The VPC id used by K8S |
| worker\_sg\_ids | The security gruop for worker group |

## aws/kube-worker

### input
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_region | The AWS region | string | `"us-east-1"` | no |
| cluster\_name | Name of the cluster. | string | n/a | yes |
| enable\_autoscaler | Enable to add autoscaler tag or not | string | `"false"` | no |
| extra\_ignition\_file\_ids | Additional ignition file IDs. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details. | list | `<list>` | no |
| extra\_ignition\_systemd\_unit\_ids | Additional ignition systemd unit IDs. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details. | list | `<list>` | no |
| extra\_tags | Extra AWS tags to be applied to created resources. | map | `<map>` | no |
| kube\_node\_labels | Labels to add when registering the node in the cluster. Labels must be key=value pairs. | list | `<list>` | no |
| kube\_node\_taints | Register the node with the given list of taints ("<key>=<value>:<effect>"). | list | `<list>` | no |
| kube\_service\_cidr |  | string | n/a | yes |
| kubelet\_flag\_extra\_flags | Extra user-provided flags to kubelet. | list | `<list>` | no |
| kubernetes\_version | Desired Kubernetes kubelet version. If you do not specify a value, the latest available version is used. | string | `"v1.13.4"` | no |
| load\_balancer\_ids | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead. | list | `<list>` | no |
| reboot\_strategy | CoreOS reboot strategies on updates, two option here: etcd-lock or off | string | `"etcd-lock"` | no |
| role\_name | The Amazon Resource Name of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. | string | `""` | no |
| s3\_bucket | Unique name under which the Amazon S3 bucket will be created. Bucket name must start with a lower case name and is limited to 63 characters.     If name is not provided the installer will construct the name using "name" and current AWS region. | string | `""` | no |
| security\_group\_ids | List of security group IDs for the cross-account elastic network interfaces     to use to allow communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| ssh\_key | The key name that should be used for the instance. | string | `""` | no |
| subnet\_ids | List of subnet IDs. Must be in at least two different availability zones.     Cross-account elastic network interfaces will be created in these subnets to allow     communication between your worker nodes and the Kubernetes control plane. | list | `<list>` | no |
| target\_group\_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing. | list | `<list>` | no |
| worker\_config | Desired worker nodes configuration. | map | `<map>` | no |