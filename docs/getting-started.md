# Getting Started Guide

## Requirements

- **Terraform**: All of the AWS resource will be create by Terraform, hence, you need to [**install it**](https://www.terraform.io/intro/getting-started/install.html) and confirm the [**permission setup**](https://www.terraform.io/docs/providers/aws/index.html) correctly, then Terraform have the permission to create AWS resource automatically. **Minimum required version of Terraform is v0.12.0**.

- **kubectl**: After the cluster created completely, there is a Kubernetes ConfigMap aws-auth need to be created through kubectl, so need to [**install it**](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl). **Minimum required version of Kubernetes is v1.18.0**.

- **[aws-iam-authenticator](https://docs.aws.amazon.com/zh_tw/eks/latest/userguide/install-aws-iam-authenticator.html)**: The clsuter access permission integrate with AWS IAM, in order to let the cluster know whether you have the right to access, aws-iam-authenticator need to be [**installed**](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) in the client side.

- **Key Pair**: In order to access worker node through ssh protocol, please create a key pair in example region **US West (Oregon) us-west-2**.

## Deploy
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
ip-10-0-48-247.ec2.internal   Ready     master    9m        v1.18.6
ip-10-0-48-117.ec2.internal   Ready     master    9m        v1.18.6
ip-10-0-66-127.ec2.internal   Ready     on-demand 5m        v1.18.6
ip-10-0-66-127.ec2.internal   Ready     on-demand 6m        v1.18.6
ip-10-0-71-121.ec2.internal   Ready     spot      3m        v1.18.6
ip-10-0-86-182.ec2.internal   Ready     spot      4m        v1.18.6
```
