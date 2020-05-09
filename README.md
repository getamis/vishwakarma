[![CircleCI](https://circleci.com/gh/getamis/vishwakarma/tree/master.svg?style=svg)](https://circleci.com/gh/getamis/vishwakarma/tree/master) [![GitHub license](https://img.shields.io/github/license/getamis/vishwakarma)](https://github.com/getamis/vishwakarma/blob/master/LICENSE)
# Vishwakarma
Vishwakarma can be used to create a Kubernetes cluster in AWS by leveraging HashiCorp Terraform and CoreOS. Of course, we didn't develop it from scratch, we refer to [CoreOS Tectonic](https://github.com/coreos/tectonic-installer), before starting to dive into the detail, let's experience it first.

![Alt text](https://cdn-images-1.medium.com/max/800/1*ocPrvGrCORzJiF3rK3GG_g.png)

## Requirements

- **Terraform**: All of the AWS resource will be create by Terraform, hence, you need to [**install it**](https://www.terraform.io/intro/getting-started/install.html) and confirm the [**permission setup**](https://www.terraform.io/docs/providers/aws/index.html) correctly, then Terraform have the permission to create AWS resource automatically. **Minimum required version of Terraform is v0.12.0**.

- **kubectl**: After the cluster created completely, there is a Kubernetes ConfigMap aws-auth need to be created through kubectl, so need to [**install it**](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl). **Minimum required version of Kubernetes is v1.10**.

- **[aws-iam-authenticator](https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/install-aws-iam-authenticator.html)**: The clsuter access permission integrate with AWS IAM, in order to let the cluster know whether you have the right to access, aws-iam-authenticator need to be [**installed**](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) in the client side.

- **Key Pair**: In order to access worker node through ssh protocol, please create a key pair in example region **US West (Oregon) us-west-2**.

## Getting Started
First, acquire Vishwakarma from github:

```sh
$ git clone https://github.com/getamis/vishwakarma.git
```

Second, before the operation, user need to create a AWS EC2 key pairs first, and input it when there is command line prompt during the operation.

```sh
# need to input the key pair name
var.key_pair_name
  The key pair name for access bastion ec2
Enter a value:
```

### Creating a Kubernetes clsuter
Please create a ssh key pair in ~/.ssh/ with the name id_rsa.pub and id_rsa, this example use the key pair for the etcd, Kubernetes master, Kubernetes node EC2 instance (refer to [**Here**](https://medium.com/getamis/elastikube-self-hosted-and-highly-configurable-kubernetes-building-blocks-97cd7afccef) for the more detail information).

```sh
# switch to kubernetes-cluster example folder
$ cd examples/kubernetes-cluster

# initial for sync terraform module and install provider plugins
$ terraform init

# create the network infrastructure
$ terraform apply -target=module.network

# create the kubernetes master compoment
$ terraform apply -target=module.master

# create the general and spot Kubernetes worker group
$ terraform apply
```

Verify the Kubernetes cluster is up! (Still keep in the same folder):

```sh
# Get the kubeconfig from S3 (The bucket name is demo-elastikube-xxxxxxxx. 
# The prefix demo-elastikube is the cluster name defined in main.tf and the rest part is an MD5.
# setup kubeconfig for kubectl to access Kubernetes cluster
$ export KUBECONFIG=#{The Path You Put kubeconfig}/kubeconfig

# check whether there is 4 worker register successfully, it will takes several minutes...
$ kubectl get node

NAME                          STATUS    ROLES     AGE       VERSION
ip-10-0-48-247.ec2.internal   Ready     master    9m        v1.15.11
ip-10-0-48-117.ec2.internal   Ready     master    9m        v1.15.11
ip-10-0-66-127.ec2.internal   Ready     on-demand 5m        v1.15.11
ip-10-0-66-127.ec2.internal   Ready     on-demand 6m        v1.15.11
ip-10-0-71-121.ec2.internal   Ready     spot      3m        v1.15.11
ip-10-0-86-182.ec2.internal   Ready     spot      4m        v1.15.11
```

## What’s Going On?
You have completed one Kubernetes cluster the same as below picture, and let me briefly explain how Vishwakarma achieves it.

![Alt text](https://cdn-images-1.medium.com/max/800/1*tvAY88CzHhxo4lBB6OUSyA.png)

## Modules
Vishwakarma include serveral major modules:

### aws/network
Create one AWS VPC including private and public subnet, and one ec2 instance called bastion hosts in public subnet, hence, one can access the resource hosting in the private subnet, refer [**aws/network**](VARIABLES.md#aws/network) for the detail variable inputs.

### aws/elastikube
This module creates the Kubernetes control plane, Terraform is responsible for the complicated Kubernetes compoments, and it takes about 10~15 minutes to complete, refer [**aws/elastikube**](VARIABLES.md#aws/elastikube) for the detail variable inputs.

### aws/kube-worker
Create a AWS auto-scaling group with CoreOS container linux and leverage ignition to provision and register to ElastiKube automatically.

Due to using AWS launch template, hence, it's up to user to choose spot or on demand instance type by changing the variable, refer [**aws/kube-worker**](VARIABLES.md#aws/kube-worker) for the detail variable inputs.

## Contributing
There are several ways to contribute to this project:

1. **Find bug**: create an issue in our Github issue tracker.
2. **Fix a bug**: check our issue tracker, leave comments and send a pull request to us to fix a bug.
3. **Make new feature**: leave your idea in the issue tracker and discuss with us then send a pull request!

## Changelog
The [Changelog](CHANGELOG.md) captures all important release notes.

## License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
