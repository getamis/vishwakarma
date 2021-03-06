<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->
# Terraform variable inputs and outputs
This document gives an overview of variables used in the AWS platform of the elastikube module.
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| allowed\_ssh\_cidr | (Optional) A list of CIDR networks to allow ssh access to. Defaults to "0.0.0.0/0" | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> |
| auth\_webhook\_kubeconfig\_path | The path of webhook kubeconfig for kube-apiserver. | `string` | `"/etc/kubernetes/config/aws-iam-authenticator/kubeconfig"` |
| certs\_validity\_period\_hours | Validity period of the self-signed certificates (in hours). Default is 10 years. | `string` | `87600` |
| enable\_iam\_auth | Enable AWS IAM authenticator or not. | `bool` | `false` |
| enable\_irsa | (Optional) Enable AWS IAM role service account or not | `bool` | `false` |
| endpoint\_public\_access | (Optional) kubernetes apiserver endpoint | `bool` | `false` |
| etcd\_instance\_config | (Optional) Desired etcd nodes configuration. | <pre>object({<br>    count              = number<br>    image_id           = string<br>    ec2_type           = string<br>    root_volume_size   = number<br>    data_volume_size   = number<br>    data_device_name   = string<br>    data_device_rename = string<br>    data_path          = string<br>  })</pre> | <pre>{<br>  "count": 1,<br>  "data_device_name": "/dev/sdf",<br>  "data_device_rename": "/dev/nvme1n1",<br>  "data_path": "/etcd/data",<br>  "data_volume_size": 100,<br>  "ec2_type": "t3.medium",<br>  "image_id": "ami-0b75e2f157200889f",<br>  "root_volume_size": 40<br>}</pre> |
| extra\_etcd\_ignition\_file\_ids | (Optional) Additional ignition file IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details. | `list(string)` | `[]` |
| extra\_etcd\_ignition\_systemd\_unit\_ids | (Optional) Additional ignition systemd unit IDs for etcds. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details. | `list(string)` | `[]` |
| extra\_ignition\_file\_ids | (Optional) Additional ignition file IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/file.html for more details. | `list(string)` | `[]` |
| extra\_ignition\_systemd\_unit\_ids | (Optional) Additional ignition systemd unit IDs for masters. See https://www.terraform.io/docs/providers/ignition/d/systemd_unit.html for more details. | `list(string)` | `[]` |
| extra\_tags | (Optional) Extra AWS tags to be applied to the resources. | `map(string)` | `{}` |
| hostzone | (Optional) The cluster private hostname. If not specified, <cluster name>.com will be used. | `string` | `""` |
| irsa\_oidc\_config | The service account config to enable pod identity feature | <pre>object({<br>    issuer        = string<br>    api_audiences = string<br>  })</pre> | <pre>{<br>  "api_audiences": "sts.amazonaws.com",<br>  "issuer": ""<br>}</pre> |
| kube\_apiserver\_secure\_port | The port on which to serve HTTPS with authentication and authorization for kube-apiserver. | `number` | `6443` |
| kube\_audit\_log\_policy\_content | The policy content for auditing log. | `string` | `"# Log all requests at the Metadata level.\napiVersion: audit.k8s.io/v1\nkind: Policy\nrules:\n- level: Metadata\n"` |
| kube\_cluster\_network\_cidr | The kubernetes cluster ip range | `string` | `"172.24.0.0/13"` |
| kube\_extra\_flags | The user-provided flags to kubelet, kube-apiserver, kube-controller-manager, kube-scheduler and audit log. <br>For flags, we need to follow component flag string format. Do not use underline. | `map` | <pre>{<br>  "apiserver": {},<br>  "audit_log": {},<br>  "controller_manager": {},<br>  "kubelet": {},<br>  "scheduler": {}<br>}</pre> |
| kube\_service\_network\_cidr | The kubernetes service ip range | `string` | `"172.16.0.0/13"` |
| kubelet\_node\_labels | Labels to add when registering the node in the cluster. Labels must be key=value pairs. | `list(string)` | `[]` |
| kubelet\_node\_taints | Register the node with the given list of taints ("<key>=<value>:<effect>"). | `list(string)` | `[]` |
| kubernetes\_version | Desired Kubernetes version. | `string` | `"v1.19.10"` |
| lb\_security\_group\_ids | (Optional) List of security group IDs for the cross-account elastic network interfaces<br>    to use to allow communication to the kubernetes api server load balancer. | `list(string)` | `[]` |
| master\_instance\_config | (Optional) Desired master nodes configuration. | <pre>object({<br>    count            = number<br>    image_id         = string<br>    ec2_type         = list(string)<br>    root_volume_iops = number<br>    root_volume_size = number<br>    root_volume_type = string<br><br>    on_demand_base_capacity                  = number<br>    on_demand_percentage_above_base_capacity = number<br>    spot_instance_pools                      = number<br>  })</pre> | <pre>{<br>  "count": 1,<br>  "ec2_type": [<br>    "t3.medium",<br>    "t2.medium"<br>  ],<br>  "image_id": "ami-0b75e2f157200889f",<br>  "on_demand_base_capacity": 0,<br>  "on_demand_percentage_above_base_capacity": 100,<br>  "root_volume_iops": 100,<br>  "root_volume_size": 256,<br>  "root_volume_type": "gp2",<br>  "spot_instance_pools": 1<br>}</pre> |
| name | (Required) Name of the cluster. | `string` | n/a |
| network\_plugin | Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc' | `string` | `"amazon-vpc"` |
| override\_binaries | Desired binaries(cni\_plugin) url and checksum. | <pre>map(object({<br>    source   = string<br>    checksum = string<br>  }))</pre> | `{}` |
| override\_containers | Desired containers(kube-apiserver, kube-controller-manager, cfssl, coredns, and so on) repo and tag. | <pre>map(object({<br>    repo = string<br>    tag  = string<br>  }))</pre> | `{}` |
| private\_subnet\_ids | (Required) List of private subnet IDs. Must be in at least two different availability zones.<br>    Cross-account elastic network interfaces will be created in these subnets to allow<br>    communication between your worker nodes and the Kubernetes control plane. | `list(string)` | `[]` |
| public\_subnet\_ids | (Required) List of public subnet IDs. Must be in at least two different availability zones.<br>    Cross-account elastic network interfaces will be created in these subnets to allow<br>    communication between your worker nodes and the Kubernetes control plane. | `list(string)` | `[]` |
| reboot\_strategy | (Optional) CoreOS reboot strategies on updates, two option here: etcd-lock or off | `string` | `"off"` |
| role\_name | (Optional) The Amazon Resource Name (ARN) of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. | `string` | `""` |
| security\_group\_ids | (Optional) List of security group IDs for the cross-account elastic network interfaces<br>    to use to allow communication between your worker nodes and the Kubernetes control plane. | `list(string)` | `[]` |
| service\_account\_content | The service account keypair content for Kubernetes. If keypair is empty, | <pre>object({<br>    pub_key = string<br>    pri_key = string<br>  })</pre> | <pre>{<br>  "pri_key": "",<br>  "pub_key": ""<br>}</pre> |
| ssh\_key | The key name that should be used for the instances. | `string` | `""` |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Kubernetes cluster endpoint. |
| etcd\_role\_name | n/a |
| id | Kubernetes cluster name. |
| ignition\_s3\_bucket | The S3 bucket for storing provision ignition file |
| master\_role\_name | n/a |
| master\_sg\_ids | The security group which used by K8S master |
| service\_account\_pub\_key | n/a |
| vpc\_id | The VPC id used by K8S |
| worker\_sg\_ids | The security gruop for worker group |

