# Kubernetes Cluster Example
This folder contains a simple Terraform module that deploys resources in [AWS](https://aws.amazon.com/) to demonstrate how you can use Terratest to write automated tests for your AWS Terraform code. This module deploys AWS VPC with bastion hot, self-hosted Kubernetes with two worker group (spot and on demand instance) [EC2 Instances](https://aws.amazon.com/ec2/) in the AWS region specified in the `aws_region` variable.

Check out [test/cluster_test.go](/test/cluster_test.go) to see how you can write automated tests for this module.

**WARNING**: This module and the automated tests for it deploy real resources into your AWS account which can cost you money.

## Running this module manually

1. Sign up for [AWS](https://aws.amazon.com/).
2. Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
3. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.

4. Execute below command to setup:

```sh
# initial for sync terraform module and install provider plugins
$ terraform init

# create the network infrastructure
$ terraform apply -target=module.network

# create the kubernetes master compoment
$ terraform apply -target=module.master

# create the general and spot k8s worker group
$ terraform apply
```

5. When you're done, execute below command to destroy:

```sh
$ terraform destroy -target=module.worker_on_demand
$ terraform destroy -target=module.worker_spot
$ terraform destroy -target=module.master
$ terraform destroy -target=module.network
```

## Running automated tests against this module

1. Sign up for [AWS](https://aws.amazon.com/).
2. Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
3. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.
4. Install [Golang](https://golang.org/) and make sure this code is checked out into your `GOPATH`.
5. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and make sure it's on your `PATH`.
6. `cd test`
7. `dep ensure`
8. `go test -timeout 60m -v -run TestKubernetesCluster`
9. If execution without error, the output like below:

```
...
agent.go:114: Generating SSH Agent with given KeyPair(s)
agent.go:68: could not serve ssh agent read unix /tmp/ssh-agent-589722746/ssh_auth.sock->@: use of closed network connection
PASS
ok  	github.com/vishwakarma/test	1223.186s
```

## How to rolling update etcd instance
 
Depend on how many etcd instaces created by this Terraform module, then below steps need to perform for the etcd instance one by one, e.g. there are three etcd instance, hence, below steps need to perform 3 times

So there should be at least 3 etcd instances in production environment, to avoid single point of failure, during the etcd rolling update process, the K8s cluster still can work without any issue

1. Terminate specific etcd instance manually from AWS console, due to the terraform imply dependncy feature, so that cannot complete 
2. Execute below command to refresh terraform state and create a new etcd instance with exist network interface and ebs volume

```sh
~$ terraform refresh
~$ terraform apply -target=module.master
```
