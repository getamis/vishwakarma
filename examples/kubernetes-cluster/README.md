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

# create the AWS resource for kubernetes cluster 
$ terraform apply
```

5. When you're done, execute below command to destroy:

```sh
$ terraform destroy
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